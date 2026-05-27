#!/usr/bin/env python3
import datetime
import json
import re
from collections import Counter
from pathlib import Path


BASE_DIR = Path("/Users/codertjay/PycharmProjects/Web3ProjectFinder/immunefi_solidity_batch_30")
SECTION_START = "<!-- AUDIT_DOSSIER_START -->"
SECTION_END = "<!-- AUDIT_DOSSIER_END -->"
OLD_JSON = "AUDIT_LIFECYCLE_FULL.json"
NEW_JSON = "AUDIT_STATE_VALUES_FULL.json"


PRAGMA_RE = re.compile(r"pragma\s+solidity\s+([^;]+);")
CONTRACT_HEAD_RE = re.compile(r"\b(abstract\s+contract|contract|interface|library)\s+([A-Za-z_]\w*)\s*(?:is\s*([^{]+))?\{")
ENUM_RE = re.compile(r"enum\s+([A-Za-z_]\w*)\s*\{([^}]*)\}", re.DOTALL)
STRUCT_RE = re.compile(r"struct\s+([A-Za-z_]\w*)\s*\{([^}]*)\}", re.DOTALL)


TOTAL_BALANCE_KEYS = (
    "total",
    "balance",
    "supply",
    "asset",
    "reserve",
    "liquidity",
    "debt",
    "borrow",
    "collateral",
    "share",
    "pool",
    "vault",
    "tvl",
    "index",
    "stake",
    "staking",
)
TOKEN_NAME_KEYS = (
    "token",
    "usdc",
    "usdt",
    "dai",
    "weth",
    "wbtc",
    "reth",
    "steth",
    "eth",
    "btc",
    "lp",
)
TOKEN_TYPE_KEYS = (
    "IERC20",
    "ERC20",
    "IERC4626",
    "ERC4626",
    "IToken",
    "IAsset",
    "IStrategy",
)
MODIFIERS = {"public", "private", "internal", "external", "constant", "immutable", "override", "payable"}
SKIP_PREFIXES = ("import ", "pragma ", "event ", "error ", "modifier ", "function ", "constructor(", "fallback(", "receive(", "using ", "enum ", "struct ", "type ")


def _clean(s: str) -> str:
    return re.sub(r"\s+", " ", s or "").strip()


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//.*", "", text)
    return text


def find_contract_regions(text: str):
    regions = []
    for m in CONTRACT_HEAD_RE.finditer(text):
        start = m.end() - 1  # points at "{"
        depth = 0
        end = None
        for i in range(start, len(text)):
            c = text[i]
            if c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end is None:
            continue
        regions.append(
            {
                "kind": _clean(m.group(1)),
                "name": _clean(m.group(2)),
                "bases": [_clean(x) for x in (m.group(3) or "").split(",") if _clean(x)],
                "body": text[start + 1 : end],
            }
        )
    return regions


def _parse_var_statement(stmt: str):
    s = _clean(stmt).rstrip(";")
    if not s:
        return None
    lower = s.lower()
    if any(lower.startswith(pref) for pref in SKIP_PREFIXES):
        return None
    if " function(" in s or s.startswith("function("):
        return None

    # Split assignment outside type arrows (`=>`) and nested brackets/parens.
    left, init = split_assignment(s)
    left = _clean(left)

    # Find variable name as the last identifier in declaration.
    m = re.search(r"([A-Za-z_]\w*)\s*(?:\[[^\]]*\])?\s*$", left)
    if not m:
        return None
    name = m.group(1)

    # Type guess = text before variable name.
    type_part = left[: m.start()].strip()
    if not type_part:
        return None

    # Normalize declaration metadata.
    vis = "default"
    for token in ("public", "private", "internal", "external"):
        if re.search(rf"\b{token}\b", left):
            vis = token
            break

    mut_flags = []
    for token in ("constant", "immutable", "override", "payable"):
        if re.search(rf"\b{token}\b", left):
            mut_flags.append(token)

    return {
        "name": name,
        "type": type_part,
        "visibility": vis,
        "flags": mut_flags,
        "initializer": init,
        "declaration": s,
    }


def split_assignment(stmt: str):
    depth_paren = 0
    depth_brack = 0
    for i, ch in enumerate(stmt):
        if ch == "(":
            depth_paren += 1
            continue
        if ch == ")":
            depth_paren = max(0, depth_paren - 1)
            continue
        if ch == "[":
            depth_brack += 1
            continue
        if ch == "]":
            depth_brack = max(0, depth_brack - 1)
            continue
        if ch == "=" and depth_paren == 0 and depth_brack == 0:
            prev_ch = stmt[i - 1] if i > 0 else ""
            next_ch = stmt[i + 1] if i + 1 < len(stmt) else ""
            if prev_ch == ">" or next_ch == ">":  # mapping arrow or similar
                continue
            return stmt[:i], _clean(stmt[i + 1 :])
    return stmt, None


def collect_contract_top_level_statements(contract_body: str):
    out = []
    depth = 0
    buf = []
    for ch in contract_body:
        if ch == "{":
            depth += 1
            buf.append(ch)
            continue
        if ch == "}":
            depth = max(0, depth - 1)
            buf.append(ch)
            continue
        if ch == ";" and depth == 0:
            stmt = "".join(buf).strip()
            if stmt:
                out.append(stmt + ";")
            buf = []
            continue
        if depth == 0:
            buf.append(ch)
    return out


def parse_structs(text: str, rel_file: str):
    structs = []
    for m in STRUCT_RE.finditer(text):
        name = _clean(m.group(1))
        body = m.group(2)
        fields = []
        for raw in body.split(";"):
            row = _clean(raw)
            if not row:
                continue
            fm = re.search(r"([A-Za-z_]\w*)\s*(?:\[[^\]]*\])?\s*$", row)
            if not fm:
                continue
            field_name = fm.group(1)
            field_type = row[: fm.start()].strip()
            fields.append({"name": field_name, "type": field_type})
        structs.append({"file": rel_file, "struct": name, "fields": fields})
    return structs


def parse_enums(text: str, rel_file: str):
    enums = []
    for m in ENUM_RE.finditer(text):
        name = _clean(m.group(1))
        vals = [_clean(v) for v in m.group(2).split(",") if _clean(v)]
        enums.append({"file": rel_file, "enum": name, "values": vals})
    return enums


def make_invariants(total_balance_vars, token_vars, structs):
    inv = []
    if total_balance_vars:
        names = [v["name"] for v in total_balance_vars]
        if any("totalSupply" == n or n.lower() == "totalsupply" for n in names) and any("balanceof" in n.lower() for n in names):
            inv.append("`sum(balanceOf[*]) == totalSupply` (token balance conservation)")
        if any("totalassets" in n.lower() for n in names) and any("totalsupply" in n.lower() for n in names):
            inv.append("`totalAssets` and `totalSupply` must stay conversion-consistent (shares/assets accounting)")
        if any("debt" in n.lower() for n in names) and any("collateral" in n.lower() for n in names):
            inv.append("Debt growth must stay bounded by collateral/liquidation constraints")
        if not inv:
            joined = ", ".join(f"`{n}`" for n in names[:8])
            inv.append(f"Key accounting vars ({joined}) must only change through authorized accounting paths")
    else:
        inv.append("No explicit total/balance variable set detected; derive invariants from function-level balance flows")

    if token_vars:
        inv.append("Every token address/handle variable must be non-zero and immutable or governance-gated")
    if structs:
        inv.append("Struct fields representing amounts/indexes/nonces must remain monotonic or strictly validated per lifecycle transition")
    return inv


def collect_project_data(project_dir: Path):
    sol_files = sorted([p for p in project_dir.rglob("*.sol") if p.is_file() and ".git" not in p.parts])
    rel_files = [str(p.relative_to(project_dir)) for p in sol_files]

    pragmas = set()
    contracts = []
    enums = []
    structs = []
    all_state_vars = []
    total_balance_vars = []
    token_vars = []
    token_addresses = []
    dir_counts = Counter()

    for path in sol_files:
        rel = str(path.relative_to(project_dir))
        dir_counts[path.relative_to(project_dir).parts[0] if len(path.relative_to(project_dir).parts) > 1 else "."] += 1
        raw = path.read_text(encoding="utf-8", errors="ignore")
        text = strip_comments(raw)

        for m in PRAGMA_RE.finditer(text):
            pragmas.add(_clean(m.group(1)))

        structs.extend(parse_structs(text, rel))
        enums.extend(parse_enums(text, rel))
        regions = find_contract_regions(text)
        for r in regions:
            contracts.append({"file": rel, "kind": r["kind"], "name": r["name"], "bases": r["bases"]})
            for stmt in collect_contract_top_level_statements(r["body"]):
                parsed = _parse_var_statement(stmt)
                if not parsed:
                    continue
                parsed["file"] = rel
                parsed["contract"] = r["name"]
                all_state_vars.append(parsed)

    # classify state vars
    seen_total = set()
    seen_token = set()
    for v in all_state_vars:
        lower_name = v["name"].lower()
        lower_type = v["type"].lower()
        lower_decl = v["declaration"].lower()

        is_total = any(k in lower_name for k in TOTAL_BALANCE_KEYS) or any(k in lower_decl for k in ("balanceof", "totalsupply", "totalassets", "totaldebt", "totalreserve"))
        if is_total:
            key = (v["file"], v["contract"], v["name"])
            if key not in seen_total:
                total_balance_vars.append(v)
                seen_total.add(key)

        is_token = any(k in lower_name for k in TOKEN_NAME_KEYS) or any(k.lower() in v["type"] for k in TOKEN_TYPE_KEYS) or "erc20" in lower_type
        if is_token:
            key = (v["file"], v["contract"], v["name"])
            if key not in seen_token:
                token_vars.append(v)
                seen_token.add(key)
                if v["initializer"] and re.fullmatch(r"0x[a-fA-F0-9]{40}", v["initializer"]):
                    token_addresses.append({"file": v["file"], "var": v["name"], "address": v["initializer"]})

    invariants = make_invariants(total_balance_vars, token_vars, structs)

    data = {
        "generated_at_utc": datetime.datetime.now(datetime.UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "project": project_dir.name,
        "solidity_file_count": len(sol_files),
        "solidity_files": rel_files,
        "pragmas": sorted(pragmas),
        "top_directories_by_solidity_file_count": dir_counts.most_common(12),
        "contracts": sorted(contracts, key=lambda x: (x["name"], x["file"])),
        "enums": sorted(enums, key=lambda x: (x["enum"], x["file"])),
        "structs": sorted(structs, key=lambda x: (x["struct"], x["file"])),
        "all_state_variables": sorted(all_state_vars, key=lambda x: (x["contract"], x["name"], x["file"])),
        "total_balance_variables": sorted(total_balance_vars, key=lambda x: (x["contract"], x["name"], x["file"])),
        "token_variables": sorted(token_vars, key=lambda x: (x["contract"], x["name"], x["file"])),
        "token_addresses_hardcoded": sorted(token_addresses, key=lambda x: (x["var"], x["file"])),
        "invariant_values": invariants,
    }
    return data


def _render_var_list(items):
    if not items:
        return ["- None detected"]
    out = []
    for it in items:
        flags = ",".join(it["flags"]) if it["flags"] else "-"
        init = f" = `{it['initializer']}`" if it["initializer"] else ""
        out.append(
            f"- `{it['name']}` | type: `{it['type']}` | vis: `{it['visibility']}` | flags: `{flags}` | `{it['contract']}` @ `{it['file']}`{init}"
        )
    return out


def _render_structs(structs):
    if not structs:
        return ["- None detected"]
    out = []
    for s in structs:
        fields = ", ".join(f"{f['type']} {f['name']}" for f in s["fields"]) if s["fields"] else "(no parsed fields)"
        out.append(f"- `{s['struct']}` ({s['file']}): {fields}")
    return out


def _render_token_addresses(items):
    if not items:
        return ["- None detected"]
    out = []
    for it in items:
        out.append(f"- `{it['var']}` @ `{it['file']}` = `{it['address']}`")
    return out


def render_markdown(data: dict) -> str:
    dir_lines = [f"- `{d}`: {n} `.sol` files" for d, n in data["top_directories_by_solidity_file_count"]] or ["- None"]
    pragma_lines = [f"- `{p}`" for p in data["pragmas"]] or ["- None detected"]
    enum_lines = [f"- `{e['enum']}` ({e['file']}): {', '.join(e['values']) if e['values'] else '(empty)'}" for e in data["enums"]] or ["- None detected"]

    md = f"""{SECTION_START}
## Protocol State/Value Dossier (Auto-Generated)

Generated (UTC): `{data['generated_at_utc']}`  
Project: `{data['project']}`  
Solidity files: `{data['solidity_file_count']}`

### Structure
Top Solidity directories:
{chr(10).join(dir_lines)}

Pragmas:
{chr(10).join(pragma_lines)}

Contracts/Libraries/Interfaces detected: `{len(data['contracts'])}`

### Life Total / Balance Values
Detected accounting/state total variables:
{chr(10).join(_render_var_list(data['total_balance_variables']))}

All detected state variables (full list):
{chr(10).join(_render_var_list(data['all_state_variables']))}

### Tokens Added / Token State Values
Detected token-related variables:
{chr(10).join(_render_var_list(data['token_variables']))}

Hardcoded token addresses found:
{chr(10).join(_render_token_addresses(data['token_addresses_hardcoded']))}

### Struct Values (All Parsed Struct Fields)
{chr(10).join(_render_structs(data['structs']))}

### Enum State Values
{chr(10).join(enum_lines)}

### Invariant Values (Variable-Tied)
{chr(10).join(f"- {x}" for x in data['invariant_values'])}

### Full Raw State Inventory
- `{NEW_JSON}` includes:
  - all state variables
  - all total/balance variables
  - all token variables
  - all structs and fields
  - enum values
{SECTION_END}
"""
    return md


def upsert_readme(project_dir: Path, rendered: str):
    readme = project_dir / "README.md"
    if readme.exists():
        original = readme.read_text(encoding="utf-8", errors="ignore")
    else:
        original = f"# {project_dir.name}\n\n"

    if SECTION_START in original and SECTION_END in original:
        pattern = re.compile(re.escape(SECTION_START) + r".*?" + re.escape(SECTION_END), re.DOTALL)
        updated = re.sub(pattern, lambda _: rendered.strip(), original).rstrip() + "\n"
    else:
        updated = original.rstrip() + "\n\n" + rendered.strip() + "\n"
    readme.write_text(updated, encoding="utf-8")


def main():
    projects = sorted([p for p in BASE_DIR.iterdir() if p.is_dir()])
    if not projects:
        raise SystemExit(f"No project directories found under {BASE_DIR}")

    for project in projects:
        data = collect_project_data(project)

        # Remove previous wrong artifact if present.
        old_path = project / OLD_JSON
        if old_path.exists():
            old_path.unlink()

        new_path = project / NEW_JSON
        new_path.write_text(json.dumps(data, indent=2), encoding="utf-8")

        md = render_markdown(data)
        upsert_readme(project, md)
        print(f"updated {project.name}: README.md + {NEW_JSON}")

    print(f"done: {len(projects)} projects updated")


if __name__ == "__main__":
    main()
