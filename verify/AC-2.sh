#!/usr/bin/env bash
# AC-2 v2 (bundle-scoped) — 词表 v3：全表≥40 / 核心≥40 / 双源≥15 / 元数据齐 / summary 一致
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, re
B = "bundle"
lex = json.load(open(f"{B}/data/lexicon.json"))
s = json.load(open(f"{B}/data/lexicon_summary.json"))
terms = lex["terms"]
core = [t for t in terms if t.get("in_core")]
dual = [t for t in terms if t.get("source") == "both"]
assert len(terms) >= 40, f"only {len(terms)} terms"
assert len(core) >= 40, f"only {len(core)} core terms"
assert len(dual) >= 15, f"only {len(dual)} dual-source terms"
assert "n_core_terms" in lex["meta"] and "n_human_docs" in lex["meta"], "lexicon meta missing keys"
assert s["n_terms"] == len(terms) and s["n_core"] == len(core) and s["n_dual_source"] == len(dual), "summary disagrees"
# every core term must satisfy its published definition: dual source AND style AND paired lift >= 1.5
for t in core:
    assert t["source"] == "both" and t["style_topic"] == "style" and t["lift_paired"] >= 1.5, f"bad core term: {t['word']}"
p = open(f"{B}/paper/paper_en.md", encoding="utf-8").read()
a = dict(re.findall(r"<!--K:([a-z0-9_.]+)=([\-0-9.]+)-->", p))
assert int(a["n_terms"]) == len(terms), "paper n_terms anchor disagrees"
print(f"AC-2 PASS terms={len(terms)} core={len(core)} dual={len(dual)} baseline={lex['meta']['n_human_docs']}")
PY
