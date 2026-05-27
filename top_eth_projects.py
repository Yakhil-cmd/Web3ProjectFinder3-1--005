#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import math
import re
import ssl
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import certifi
except ImportError:
    certifi = None  # type: ignore[assignment]


LLAMA_PROTOCOLS_URL = "https://api.llama.fi/protocols"
LLAMA_DEXS_OVERVIEW_URL = "https://api.llama.fi/overview/dexs"
LLAMA_FEES_OVERVIEW_URL = "https://api.llama.fi/overview/fees"
CANONICAL_OUTPUT_JSON = "top_eth_projects.json"

DEFAULT_MIN_USD = 20_000.0
DEFAULT_LIMIT = 20
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
DEFAULT_PROFILE = "hunter"
DEFAULT_HUNTER_MAX_AUDITS = 2

MEV_CATEGORY_WEIGHTS: dict[str, float] = {
    "Dexs": 1.60,
    "DEX Aggregator": 1.30,
    "Lending": 1.40,
    "CDP": 1.35,
    "Derivatives": 1.25,
    "Options": 1.20,
    "Synthetics": 1.15,
    "Basis Trading": 1.15,
    "Leveraged Farming": 1.05,
    "RWA Lending": 1.10,
    "NFT Lending": 1.00,
}
DEFAULT_MEV_CATEGORIES = tuple(MEV_CATEGORY_WEIGHTS.keys())
DEX_LIKE_CATEGORIES = {"Dexs", "DEX Aggregator"}
LIQUIDATION_LIKE_CATEGORIES = {"Lending", "CDP", "RWA Lending", "NFT Lending"}
EVM_ADDRESS_RE = re.compile(r"0x[a-fA-F0-9]{40}")


class ScanError(RuntimeError):
    pass


@dataclass(frozen=True)
class Candidate:
    rank: int
    name: str
    slug: str
    category: str
    audits_count: int | None
    parent_protocol: str | None
    chain: str
    chain_tvl_usd: float
    dex_volume_24h_usd: float
    fees_24h_usd: float
    mev_score: float
    representative_address: str | None
    website: str | None
    signals: list[str]


def candidate_to_target(candidate: Candidate) -> dict[str, Any]:
    return {
        "rank": candidate.rank,
        "project": {
            "name": candidate.name,
            "slug": candidate.slug,
            "category": candidate.category,
            "parent_protocol": candidate.parent_protocol,
            "audits_count": candidate.audits_count,
        },
        "addressing": {
            "chain": candidate.chain,
            "representative_address": candidate.representative_address,
            "website": candidate.website,
        },
        "metrics": {
            "chain_tvl_usd": candidate.chain_tvl_usd,
            "dex_volume_24h_usd": candidate.dex_volume_24h_usd,
            "fees_24h_usd": candidate.fees_24h_usd,
            "mev_score": candidate.mev_score,
        },
        "signals": candidate.signals,
    }


def build_ssl_context() -> ssl.SSLContext:
    if certifi is not None:
        return ssl.create_default_context(cafile=certifi.where())
    return ssl.create_default_context()


SSL_CONTEXT = build_ssl_context()


def fetch_json(url: str, *, timeout: int = 30) -> Any:
    req = urllib.request.Request(
        url=url,
        headers={
            "Accept": "application/json,text/plain,*/*",
            "User-Agent": "mev-project-scanner/1.0",
        },
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=SSL_CONTEXT) as response:
            raw = response.read()
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise ScanError(f"GET {url} failed ({exc.code}): {detail[:300]}") from exc
    except urllib.error.URLError as exc:
        detail = str(exc)
        if "CERTIFICATE_VERIFY_FAILED" in detail:
            raise ScanError(
                f"GET {url} failed: {exc}. "
                "TLS certificate verification failed; install certifi in your active env "
                "(`python -m pip install certifi`)."
            ) from exc
        raise ScanError(f"GET {url} failed: {exc}") from exc

    try:
        return json.loads(raw.decode("utf-8", errors="replace"))
    except json.JSONDecodeError as exc:
        raise ScanError(f"invalid JSON from {url}") from exc


def norm_chain(name: str) -> str:
    text = name.strip().lower()
    aliases = {
        "eth": "ethereum",
        "ethereum mainnet": "ethereum",
        "mainnet": "ethereum",
        "op mainnet": "optimism",
    }
    return aliases.get(text, text)


def safe_float(value: Any) -> float:
    if isinstance(value, bool):
        return 0.0
    if isinstance(value, (int, float)):
        return float(value)
    return 0.0


def parse_audits_count(value: Any) -> int | None:
    if value is None:
        return None
    if isinstance(value, bool):
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
        if text:
            return text
    return None


def extract_representative_address(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    match = EVM_ADDRESS_RE.search(text)
    if match is None:
        return None
    candidate = match.group(0)
    if candidate.lower() == "0x0000000000000000000000000000000000000000":
        return None
    return candidate


def parse_keyword_list(raw: str | None, *, default: tuple[str, ...] = ()) -> list[str]:
    if raw is None:
        return [item.lower() for item in default if item.strip()]
    out: list[str] = []
    for part in raw.split(","):
        item = part.strip().lower()
        if item:
            out.append(item)
    return out


def protocol_text_blob(protocol: dict[str, Any]) -> str:
    fields: list[str] = []
    for key in ("name", "slug", "parentProtocol", "module", "category"):
        value = protocol.get(key)
        if isinstance(value, str) and value.strip():
            fields.append(value.strip().lower())

    linked = protocol.get("linkedProtocols")
    if isinstance(linked, list):
        for item in linked:
            if isinstance(item, str) and item.strip():
                fields.append(item.strip().lower())

    return " | ".join(fields)


def matches_any_keyword(text_blob: str, keywords: list[str]) -> bool:
    if not text_blob or not keywords:
        return False
    for kw in keywords:
        if kw in text_blob:
            return True
    return False


def get_chain_tvl(protocol: dict[str, Any], chain: str) -> float:
    wanted = norm_chain(chain)
    chain_tvls = protocol.get("chainTvls")
    if isinstance(chain_tvls, dict):
        for key, value in chain_tvls.items():
            if norm_chain(str(key)) == wanted:
                return safe_float(value)

    # Fallback: if protocol is single-chain and matches.
    if norm_chain(str(protocol.get("chain", ""))) == wanted:
        return safe_float(protocol.get("tvl"))
    return 0.0


def get_chain_metric_from_breakdown(row: dict[str, Any], chain: str) -> float:
    breakdown = row.get("breakdown24h")
    if not isinstance(breakdown, dict):
        return 0.0

    wanted = norm_chain(chain)
    for chain_key, chain_payload in breakdown.items():
        if norm_chain(str(chain_key)) != wanted:
            continue

        if isinstance(chain_payload, dict):
            total = 0.0
            for value in chain_payload.values():
                total += safe_float(value)
            return total
        return safe_float(chain_payload)

    return 0.0


def build_chain_metric_map(overview_payload: dict[str, Any], chain: str) -> dict[str, float]:
    protocols = overview_payload.get("protocols")
    if not isinstance(protocols, list):
        return {}

    output: dict[str, float] = {}
    for row in protocols:
        if not isinstance(row, dict):
            continue
        slug = str(row.get("slug", "")).strip()
        if not slug:
            continue
        output[slug] = get_chain_metric_from_breakdown(row, chain)
    return output


def category_weight(category: str) -> float:
    return MEV_CATEGORY_WEIGHTS.get(category, 1.0)


def build_signals(*, category: str, tvl: float, dex_24h: float, fees_24h: float) -> list[str]:
    signals: list[str] = []
    if category in {"Dexs", "DEX Aggregator"}:
        signals.append("dex-arbitrage-surface")
    if category in {"Lending", "CDP", "RWA Lending", "NFT Lending"}:
        signals.append("liquidation-surface")
    if category in {"Derivatives", "Options", "Synthetics"}:
        signals.append("derivatives-orderflow")
    if dex_24h >= 1_000_000:
        signals.append("high-dex-flow-24h")
    if fees_24h >= 100_000:
        signals.append("high-fee-flow-24h")
    if tvl >= 100_000_000:
        signals.append("deep-liquidity")
    return signals


def compute_mev_score(*, category: str, tvl: float, dex_24h: float, fees_24h: float) -> float:
    # Log scales make ranking stable across protocols with very different sizes.
    tvl_component = 1.70 * category_weight(category) * math.log10(max(1.0, tvl))

    if category in DEX_LIKE_CATEGORIES:
        activity_component = 1.25 * math.log10(1.0 + max(0.0, dex_24h))
        activity_component += 0.85 * math.log10(1.0 + max(0.0, fees_24h))
        category_bonus = 2.10
    elif category in LIQUIDATION_LIKE_CATEGORIES:
        activity_component = 1.25 * math.log10(1.0 + max(0.0, fees_24h))
        activity_component += 0.45 * math.log10(1.0 + max(0.0, dex_24h))
        category_bonus = 2.40
    else:
        activity_component = 0.90 * math.log10(1.0 + max(0.0, dex_24h))
        activity_component += 1.00 * math.log10(1.0 + max(0.0, fees_24h))
        category_bonus = 1.80

    return tvl_component + activity_component + category_bonus


def sort_and_rank(candidates: list[Candidate], limit: int, *, sort_by: str) -> list[Candidate]:
    sort_key = sort_by.lower().strip()
    if sort_key == "tvl":
        ordered = sorted(candidates, key=lambda c: c.chain_tvl_usd, reverse=True)
    elif sort_key == "dex24h":
        ordered = sorted(candidates, key=lambda c: c.dex_volume_24h_usd, reverse=True)
    elif sort_key == "fees24h":
        ordered = sorted(candidates, key=lambda c: c.fees_24h_usd, reverse=True)
    else:
        ordered = sorted(candidates, key=lambda c: c.mev_score, reverse=True)
    ranked: list[Candidate] = []
    for idx, row in enumerate(ordered[:limit], start=1):
        ranked.append(
            Candidate(
                rank=idx,
                name=row.name,
                slug=row.slug,
                category=row.category,
                audits_count=row.audits_count,
                parent_protocol=row.parent_protocol,
                chain=row.chain,
                chain_tvl_usd=row.chain_tvl_usd,
                dex_volume_24h_usd=row.dex_volume_24h_usd,
                fees_24h_usd=row.fees_24h_usd,
                mev_score=row.mev_score,
                representative_address=row.representative_address,
                website=row.website,
                signals=row.signals,
            )
        )
    return ranked


def render_table(rows: list[Candidate]) -> str:
    if not rows:
        return "No projects matched your filters."

    lines: list[str] = []
    header = (
        f"{'Rank':<4}  {'Project':<25}  {'Category':<18}  {'Audits':>6}  "
        f"{'TVL(USD)':>14}  {'DEX24h(USD)':>14}  {'Fees24h(USD)':>14}  {'Score':>8}"
    )
    lines.append(header)
    lines.append("-" * len(header))

    for row in rows:
        lines.append(
            f"{row.rank:<4}  "
            f"{row.name[:25]:<25}  "
            f"{row.category[:18]:<18}  "
            f"{(row.audits_count if row.audits_count is not None else 'n/a'):>6}  "
            f"{row.chain_tvl_usd:>14,.0f}  "
            f"{row.dex_volume_24h_usd:>14,.0f}  "
            f"{row.fees_24h_usd:>14,.0f}  "
            f"{row.mev_score:>8.2f}"
        )
    return "\n".join(lines)


def parse_categories(raw: str | None) -> set[str]:
    if not raw:
        return set(DEFAULT_MEV_CATEGORIES)
    out: set[str] = set()
    for part in raw.split(","):
        item = part.strip()
        if item:
            out.add(item)
    return out


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Rank top EVM projects for searcher-style MEV opportunities "
            "using chain TVL, DEX flow, and fee flow."
        )
    )
    parser.add_argument(
        "--profile",
        choices=("custom", "hunter"),
        default=DEFAULT_PROFILE,
        help=(
            "Target selection profile. "
            "'hunter' defaults to under-audited independent protocols "
            "and excludes heavily-audited families/forks."
        ),
    )
    parser.add_argument(
        "--chain",
        default="Ethereum",
        help="Chain name as used by DefiLlama (default: Ethereum).",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=DEFAULT_LIMIT,
        help=(
            f"Maximum projects in output (default: {DEFAULT_LIMIT}). "
            "Use 0 to return all matching projects."
        ),
    )
    parser.add_argument(
        "--min-usd",
        type=float,
        default=DEFAULT_MIN_USD,
        help=f"Minimum chain TVL in USD (default: {DEFAULT_MIN_USD:.0f}).",
    )
    parser.add_argument(
        "--max-usd",
        type=float,
        help="Maximum chain TVL in USD. Use to avoid very large/high-attention protocols.",
    )
    parser.add_argument(
        "--categories",
        help=(
            "Comma-separated categories to include. If omitted, defaults to "
            f"{', '.join(DEFAULT_MEV_CATEGORIES)}."
        ),
    )
    parser.add_argument(
        "--all-categories",
        action="store_true",
        help="Disable category filter and include all categories.",
    )
    parser.add_argument(
        "--max-audits",
        type=int,
        help=(
            "Keep only protocols with audits count <= this value. "
            "Example: --max-audits 1 excludes protocols with multiple audits."
        ),
    )
    parser.add_argument(
        "--independent-only",
        action="store_true",
        help=(
            "Keep only protocols with no parentProtocol. "
            "Useful for dropping many forks/family variants."
        ),
    )
    parser.add_argument(
        "--exclude-known-families",
        action="store_true",
        help=(
            "Exclude protocols matching known large protocol families "
            "(name/slug/parent/module keyword match)."
        ),
    )
    parser.add_argument(
        "--exclude-keywords",
        help=(
            "Extra comma-separated keywords to exclude "
            "(matched against name/slug/parent/module/linked protocols)."
        ),
    )
    parser.add_argument(
        "--require-representative-address",
        action="store_true",
        help="Keep only protocols with a valid EVM representative_address.",
    )
    parser.add_argument(
        "--max-dex-24h-usd",
        type=float,
        help="Maximum 24h DEX volume on selected chain in USD.",
    )
    parser.add_argument(
        "--max-fees-24h-usd",
        type=float,
        help="Maximum 24h fee flow on selected chain in USD.",
    )
    parser.add_argument(
        "--sort-by",
        choices=("score", "tvl", "dex24h", "fees24h"),
        default="score",
        help="Ranking key: score (default), tvl, dex24h, or fees24h.",
    )
    parser.add_argument(
        "--output-json",
        default=CANONICAL_OUTPUT_JSON,
        help=(
            "Deprecated. Output always writes to top_eth_projects.json "
            "to keep a single canonical file."
        ),
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    chain = args.chain.strip()
    if not chain:
        print("error: --chain must not be empty", file=sys.stderr)
        return 2
    if args.limit < 0:
        print("error: --limit must be >= 0", file=sys.stderr)
        return 2
    if args.min_usd < 0:
        print("error: --min-usd must be >= 0", file=sys.stderr)
        return 2
    if args.max_usd is not None and args.max_usd < 0:
        print("error: --max-usd must be >= 0", file=sys.stderr)
        return 2
    if args.max_usd is not None and args.max_usd < args.min_usd:
        print("error: --max-usd must be >= --min-usd", file=sys.stderr)
        return 2
    if args.max_audits is not None and args.max_audits < 0:
        print("error: --max-audits must be >= 0", file=sys.stderr)
        return 2
    if args.max_dex_24h_usd is not None and args.max_dex_24h_usd < 0:
        print("error: --max-dex-24h-usd must be >= 0", file=sys.stderr)
        return 2
    if args.max_fees_24h_usd is not None and args.max_fees_24h_usd < 0:
        print("error: --max-fees-24h-usd must be >= 0", file=sys.stderr)
        return 2
    if args.output_json != CANONICAL_OUTPUT_JSON:
        print(
            f"note: --output-json is ignored; writing to {CANONICAL_OUTPUT_JSON}",
            file=sys.stderr,
        )

    profile = args.profile
    effective_max_audits = args.max_audits
    effective_independent_only = bool(args.independent_only)
    effective_exclude_known_families = bool(args.exclude_known_families)
    effective_require_representative_address = bool(args.require_representative_address)
    if profile == "hunter":
        if effective_max_audits is None:
            effective_max_audits = DEFAULT_HUNTER_MAX_AUDITS
        effective_independent_only = True
        effective_exclude_known_families = True
        effective_require_representative_address = True

    allowed_categories = parse_categories(args.categories)
    family_keywords = parse_keyword_list(
        args.exclude_keywords,
        default=DEFAULT_KNOWN_FAMILY_KEYWORDS if effective_exclude_known_families else (),
    )
    try:
        protocols_payload = fetch_json(LLAMA_PROTOCOLS_URL)
        dex_overview = fetch_json(LLAMA_DEXS_OVERVIEW_URL)
        fees_overview = fetch_json(LLAMA_FEES_OVERVIEW_URL)
    except ScanError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    if not isinstance(protocols_payload, list):
        print("error: unexpected /protocols response shape", file=sys.stderr)
        return 1

    dex_24h_by_slug = build_chain_metric_map(dex_overview, chain)
    fees_24h_by_slug = build_chain_metric_map(fees_overview, chain)

    candidates: list[Candidate] = []
    for protocol in protocols_payload:
        if not isinstance(protocol, dict):
            continue

        category = str(protocol.get("category", "")).strip() or "Unknown"
        if not args.all_categories and category not in allowed_categories:
            continue

        parent_protocol = parse_parent_protocol(protocol.get("parentProtocol"))
        if effective_independent_only and parent_protocol is not None:
            continue

        if family_keywords:
            blob = protocol_text_blob(protocol)
            if matches_any_keyword(blob, family_keywords):
                continue

        chain_tvl = get_chain_tvl(protocol, chain)
        if chain_tvl < args.min_usd:
            continue
        if args.max_usd is not None and chain_tvl > args.max_usd:
            continue

        audits_count = parse_audits_count(protocol.get("audits"))
        if effective_max_audits is not None:
            if audits_count is None or audits_count > effective_max_audits:
                continue

        slug = str(protocol.get("slug", "")).strip()
        if not slug:
            continue

        dex_24h = dex_24h_by_slug.get(slug, 0.0)
        fees_24h = fees_24h_by_slug.get(slug, 0.0)
        if args.max_dex_24h_usd is not None and dex_24h > args.max_dex_24h_usd:
            continue
        if args.max_fees_24h_usd is not None and fees_24h > args.max_fees_24h_usd:
            continue

        score = compute_mev_score(category=category, tvl=chain_tvl, dex_24h=dex_24h, fees_24h=fees_24h)

        address = protocol.get("address")
        representative_address = extract_representative_address(address)
        if effective_require_representative_address and representative_address is None:
            continue
        website = protocol.get("url")
        website_url = str(website).strip() if isinstance(website, str) and website.strip() else None

        candidates.append(
            Candidate(
                rank=0,
                name=str(protocol.get("name", "")).strip() or slug,
                slug=slug,
                category=category,
                audits_count=audits_count,
                parent_protocol=parent_protocol,
                chain=chain,
                chain_tvl_usd=chain_tvl,
                dex_volume_24h_usd=dex_24h,
                fees_24h_usd=fees_24h,
                mev_score=score,
                representative_address=representative_address,
                website=website_url,
                signals=build_signals(category=category, tvl=chain_tvl, dex_24h=dex_24h, fees_24h=fees_24h),
            )
        )

    requested_limit = args.limit if args.limit > 0 else len(candidates)
    top = sort_and_rank(candidates, limit=requested_limit, sort_by=args.sort_by)

    output_payload = {
        "generated_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "selection_profile": {
            "profile": profile,
            "chain": chain,
            "categories": sorted(allowed_categories),
            "sort_by": args.sort_by,
            "limit_requested": args.limit,
            "limit_effective": requested_limit,
            "min_usd": args.min_usd,
            "max_usd": args.max_usd,
            "max_audits": effective_max_audits,
            "independent_only": effective_independent_only,
            "exclude_known_families": effective_exclude_known_families,
            "exclude_keywords": family_keywords,
            "require_representative_address": effective_require_representative_address,
            "max_dex_24h_usd": args.max_dex_24h_usd,
            "max_fees_24h_usd": args.max_fees_24h_usd,
            "all_categories": bool(args.all_categories),
        },
        "summary": {
            "matched_candidates_before_ranking": len(candidates),
            "targets_returned": len(top),
        },
        "data_source": {
            "protocols": LLAMA_PROTOCOLS_URL,
            "dex_overview": LLAMA_DEXS_OVERVIEW_URL,
            "fees_overview": LLAMA_FEES_OVERVIEW_URL,
        },
        "targets": [candidate_to_target(row) for row in top],
    }

    out_path = Path(CANONICAL_OUTPUT_JSON).resolve()
    out_path.write_text(json.dumps(output_payload, indent=2, ensure_ascii=True) + "\n", encoding="utf-8")

    print(render_table(top))
    print("")
    print(f"Saved JSON: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
