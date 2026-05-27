#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ADDRESS_RE = re.compile(r"^0x[a-fA-F0-9]{40}$")
RANKED_DIR_RE = re.compile(r"^\d{6}_.+")

DEFAULT_PROFILE = "hunter"
DEFAULT_HUNTER_MAX_AUDITS = 2
DEFAULT_KNOWN_FAMILY_KEYWORDS = (
    "uniswap",
    "balancer",
    "curve",
    "pancakeswap",
    "sushiswap",
    "bancor",
    "aave",
    "compound",
    "maker",
    "sky",
    "morpho",
    "spark",
    "lido",
    "ethena",
    "maple",
    "frax",
    "dodo",
    "1inch",
    "yearn",
    "gmx",
    "dydx",
    "synthetix",
    "liquity",
    "notional",
    "rocket-pool",
    "pendle",
    "camelot",
    "trader-joe",
    "convex",
    "aerodrome",
    "velodrome",
)


@dataclass(frozen=True)
class BatchTarget:
    index: int
    original_rank: int | None
    name: str
    slug: str
    category: str
    audits_count: int | None
    parent_protocol: str | None
    address: str


@dataclass(frozen=True)
class BatchResult:
    index: int
    rank: int
    slug: str
    address: str
    status: str
    duration_sec: float
    message: str
    created_path: str | None


@dataclass(frozen=True)
class SkippedTarget:
    index: int
    slug: str
    address: str
    reason: str


def slugify(text: str) -> str:
    normalized = re.sub(r"[^a-zA-Z0-9]+", "_", text.strip().lower())
    return normalized.strip("_") or "contract"


def parse_keyword_list(raw: str | None, *, default: tuple[str, ...] = ()) -> list[str]:
    if raw is None:
        return [item.lower() for item in default if item.strip()]
    output: list[str] = []
    for part in raw.split(","):
        item = part.strip().lower()
        if item:
            output.append(item)
    return output


def parse_audits_count(value: Any) -> int | None:
    if value is None or isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value if value >= 0 else None
    if isinstance(value, str):
        text = value.strip()
        if text.isdigit():
            return int(text)
    return None


def parse_parent_protocol(value: Any) -> str | None:
    if isinstance(value, str):
        text = value.strip()
        return text or None
    return None


def target_text_blob(target: BatchTarget) -> str:
    fields = [
        target.name.lower(),
        target.slug.lower(),
        target.category.lower(),
        (target.parent_protocol or "").lower(),
    ]
    return " | ".join(item for item in fields if item)


def matches_any_keyword(text: str, keywords: list[str]) -> bool:
    if not text or not keywords:
        return False
    return any(keyword in text for keyword in keywords)


def parse_targets(payload: dict[str, Any]) -> list[BatchTarget]:
    raw_targets = payload.get("targets")
    if not isinstance(raw_targets, list):
        raise ValueError("input JSON must contain a top-level 'targets' array")

    targets: list[BatchTarget] = []
    for idx, row in enumerate(raw_targets, start=1):
        if not isinstance(row, dict):
            continue

        project = row.get("project")
        project = project if isinstance(project, dict) else {}
        addressing = row.get("addressing")
        addressing = addressing if isinstance(addressing, dict) else {}

        rank_value = row.get("rank")
        original_rank = rank_value if isinstance(rank_value, int) else None

        name_raw = project.get("name") or project.get("slug") or f"target_{idx}"
        name = str(name_raw).strip() or f"target_{idx}"
        slug_raw = project.get("slug") or project.get("name") or f"target_{idx}"
        slug = slugify(str(slug_raw))

        category_raw = project.get("category")
        category = str(category_raw).strip() if isinstance(category_raw, str) else ""
        audits_count = parse_audits_count(project.get("audits_count"))
        parent_protocol = parse_parent_protocol(project.get("parent_protocol"))

        address_raw = addressing.get("representative_address")
        address = str(address_raw).strip() if isinstance(address_raw, str) else ""
        if not ADDRESS_RE.fullmatch(address):
            continue

        targets.append(
            BatchTarget(
                index=idx,
                original_rank=original_rank,
                name=name,
                slug=slug,
                category=category,
                audits_count=audits_count,
                parent_protocol=parent_protocol,
                address=address,
            )
        )

    return targets


def extract_created_path(stdout_text: str) -> str | None:
    for line in reversed(stdout_text.splitlines()):
        line = line.strip()
        if line.startswith("Created: "):
            return line.replace("Created: ", "", 1).strip()
    return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Batch-run bootstrap_scan_project.py for targets in top_eth_projects.json"
    )
    parser.add_argument(
        "--profile",
        choices=("custom", "hunter"),
        default=DEFAULT_PROFILE,
        help=(
            "Selection profile before bootstrapping. "
            "'hunter' excludes heavily-audited families/forks by default."
        ),
    )
    parser.add_argument(
        "--max-audits",
        type=int,
        help="Keep only targets with audits_count <= this value.",
    )
    parser.add_argument(
        "--independent-only",
        action="store_true",
        help="Keep only targets with no parent protocol.",
    )
    parser.add_argument(
        "--exclude-known-families",
        action="store_true",
        help="Exclude targets that match known heavily-audited protocol families.",
    )
    parser.add_argument(
        "--exclude-keywords",
        help="Extra comma-separated exclusion keywords matched against target metadata.",
    )
    parser.add_argument(
        "--clean-generated-folders",
        action="store_true",
        help=(
            "Delete all existing generated rank folders matching ^[0-9]{6}_ under output root "
            "before processing."
        ),
    )
    parser.add_argument(
        "--targets-file",
        default="top_eth_projects.json",
        help="Input targets JSON file (default: top_eth_projects.json).",
    )
    parser.add_argument(
        "--report-file",
        default="bootstrap_batch_report.json",
        help="Where to write execution report JSON (default: bootstrap_batch_report.json).",
    )
    parser.add_argument(
        "--base-rank",
        type=int,
        required=True,
        help="Starting rank prefix. Each target increments this by +1.",
    )
    parser.add_argument(
        "--network",
        default="eth",
        help="Network value passed to bootstrap_scan_project.py (default: eth).",
    )
    parser.add_argument(
        "--rpc-url",
        default="https://ethereum-rpc.publicnode.com",
        help="RPC URL passed to bootstrap_scan_project.py.",
    )
    parser.add_argument(
        "--limit-targets",
        type=int,
        help="Optional cap on number of filtered targets to process.",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=180,
        help="Per-target subprocess timeout in seconds (default: 180).",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Pass --force to bootstrap_scan_project.py.",
    )
    parser.add_argument(
        "--with-related",
        action="store_true",
        help="Pass --with-related to bootstrap_scan_project.py.",
    )
    parser.add_argument(
        "--related-limit",
        type=int,
        default=20,
        help="Pass --related-limit when --with-related is used (default: 20).",
    )
    parser.add_argument(
        "--output-root",
        help="Optional output root passed to bootstrap_scan_project.py.",
    )
    parser.add_argument(
        "--no-html",
        action="store_true",
        default=True,
        help="Pass --no-html to bootstrap_scan_project.py (default behavior).",
    )
    parser.add_argument(
        "--with-html",
        dest="no_html",
        action="store_false",
        help="Do not pass --no-html (enable explorer HTML capture).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.max_audits is not None and args.max_audits < 0:
        print("error: --max-audits must be >= 0", file=sys.stderr)
        return 2
    if args.base_rank < 0:
        print("error: --base-rank must be >= 0", file=sys.stderr)
        return 2
    if args.limit_targets is not None and args.limit_targets < 0:
        print("error: --limit-targets must be >= 0", file=sys.stderr)
        return 2
    if args.timeout_sec <= 0:
        print("error: --timeout-sec must be > 0", file=sys.stderr)
        return 2
    if args.related_limit < 0:
        print("error: --related-limit must be >= 0", file=sys.stderr)
        return 2

    targets_path = Path(args.targets_file).resolve()
    if not targets_path.exists():
        print(f"error: targets file not found: {targets_path}", file=sys.stderr)
        return 1

    try:
        payload = json.loads(targets_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"error: invalid JSON in {targets_path}: {exc}", file=sys.stderr)
        return 1

    try:
        all_targets = parse_targets(payload)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    effective_max_audits = args.max_audits
    effective_independent_only = bool(args.independent_only)
    effective_exclude_known_families = bool(args.exclude_known_families)
    if args.profile == "hunter":
        if effective_max_audits is None:
            effective_max_audits = DEFAULT_HUNTER_MAX_AUDITS
        effective_independent_only = True
        effective_exclude_known_families = True

    family_keywords = parse_keyword_list(
        args.exclude_keywords,
        default=DEFAULT_KNOWN_FAMILY_KEYWORDS if effective_exclude_known_families else (),
    )

    targets: list[BatchTarget] = []
    skipped_targets: list[SkippedTarget] = []
    for target in all_targets:
        if effective_independent_only and target.parent_protocol:
            skipped_targets.append(
                SkippedTarget(
                    index=target.index,
                    slug=target.slug,
                    address=target.address,
                    reason=f"parent_protocol={target.parent_protocol}",
                )
            )
            continue

        if effective_max_audits is not None:
            if target.audits_count is None:
                skipped_targets.append(
                    SkippedTarget(
                        index=target.index,
                        slug=target.slug,
                        address=target.address,
                        reason="audits_count=unknown",
                    )
                )
                continue
            if target.audits_count > effective_max_audits:
                skipped_targets.append(
                    SkippedTarget(
                        index=target.index,
                        slug=target.slug,
                        address=target.address,
                        reason=f"audits_count={target.audits_count}",
                    )
                )
                continue

        if family_keywords and matches_any_keyword(target_text_blob(target), family_keywords):
            skipped_targets.append(
                SkippedTarget(
                    index=target.index,
                    slug=target.slug,
                    address=target.address,
                    reason="matched_exclusion_keyword",
                )
            )
            continue

        targets.append(target)

    if args.limit_targets is not None:
        targets = targets[: args.limit_targets]

    if not targets:
        print("No valid targets found after filtering.")
        return 0

    output_root = Path(args.output_root).resolve() if args.output_root else Path(".").resolve()
    deleted_folders: list[str] = []
    if args.clean_generated_folders:
        for child in output_root.iterdir():
            if child.is_dir() and RANKED_DIR_RE.fullmatch(child.name):
                shutil.rmtree(child)
                deleted_folders.append(str(child))
        print(f"Deleted generated folders: {len(deleted_folders)}")

    results: list[BatchResult] = []
    batch_start = time.time()
    total = len(targets)
    print(
        f"Starting batch for {total} target(s) "
        f"(skipped={len(skipped_targets)}, profile={args.profile})"
    )

    for ordinal, target in enumerate(targets, start=1):
        rank = args.base_rank + ordinal
        cmd = [
            sys.executable,
            "bootstrap_scan_project.py",
            "--rank",
            str(rank),
            "--slug",
            target.slug,
            "--address",
            target.address,
            "--network",
            args.network,
            "--rpc-url",
            args.rpc_url,
        ]
        if effective_exclude_known_families:
            cmd.append("--reject-known-families")
        if family_keywords:
            cmd.extend(["--reject-keywords", ",".join(family_keywords)])
        if args.no_html:
            cmd.append("--no-html")
        if args.force:
            cmd.append("--force")
        if args.output_root:
            cmd.extend(["--output-root", args.output_root])
        if args.with_related:
            cmd.append("--with-related")
            cmd.extend(["--related-limit", str(args.related_limit)])

        start = time.time()
        try:
            proc = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=args.timeout_sec,
                check=False,
            )
            duration = round(time.time() - start, 2)
            created_path = extract_created_path(proc.stdout)
            if proc.returncode == 0:
                status = "ok"
                message = proc.stdout.strip().splitlines()[-1] if proc.stdout.strip() else "ok"
            else:
                status = "failed"
                message = (
                    proc.stderr.strip().splitlines()[-1]
                    if proc.stderr.strip()
                    else (proc.stdout.strip().splitlines()[-1] if proc.stdout.strip() else "unknown error")
                )
        except subprocess.TimeoutExpired:
            duration = round(time.time() - start, 2)
            status = "timeout"
            message = f"timeout>{args.timeout_sec}s"
            created_path = None

        result = BatchResult(
            index=target.index,
            rank=rank,
            slug=target.slug,
            address=target.address,
            status=status,
            duration_sec=duration,
            message=message,
            created_path=created_path,
        )
        results.append(result)
        print(f"[{ordinal}/{total}] {status} {target.slug} {target.address} ({duration}s)")

    ok_count = sum(1 for row in results if row.status == "ok")
    failed_count = sum(1 for row in results if row.status == "failed")
    timeout_count = sum(1 for row in results if row.status == "timeout")

    report_payload = {
        "generated_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "input_file": str(targets_path),
        "profile": args.profile,
        "max_audits": effective_max_audits,
        "independent_only": effective_independent_only,
        "exclude_known_families": effective_exclude_known_families,
        "exclude_keywords": family_keywords,
        "base_rank": args.base_rank,
        "network": args.network,
        "rpc_url": args.rpc_url,
        "with_related": bool(args.with_related),
        "related_limit": args.related_limit if args.with_related else None,
        "force": bool(args.force),
        "total_targets": total,
        "ok": ok_count,
        "failed": failed_count,
        "timeout": timeout_count,
        "skipped_by_filter": len(skipped_targets),
        "deleted_folders_count": len(deleted_folders),
        "deleted_folders": deleted_folders,
        "elapsed_sec": round(time.time() - batch_start, 2),
        "skipped_targets": [asdict(row) for row in skipped_targets],
        "results": [asdict(row) for row in results],
    }

    report_path = Path(args.report_file).resolve()
    report_path.write_text(json.dumps(report_payload, indent=2) + "\n", encoding="utf-8")

    print("---")
    print(
        f"done: ok={ok_count} failed={failed_count} timeout={timeout_count} "
        f"skipped={len(skipped_targets)} total={total}"
    )
    print(f"report: {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
