#!/usr/bin/env bash
# AC-1 v2 (bundle-scoped) — 语料事实：≥120k 行 / ≥18 领域 / 年份含关键年 / 每年≥3000；
# 三源交叉：sample_facts.json == index.html EMBEDDED meta == 论文 K 锚点
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, re
B = "bundle"
facts = json.load(open(f"{B}/data/sample_facts.json"))
import csv
rows = list(csv.DictReader(open(f"{B}/data/field_year_counts.csv")))
assert facts["n_docs"] >= 120_000, f"only {facts['n_docs']} docs"
assert facts["n_fields"] >= 18, f"only {facts['n_fields']} fields"
assert {2015, 2019, 2022, 2023, 2026} <= set(facts["years"]), "missing key years"
assert facts["min_year_n"] >= 3000, f"thinnest year {facts['min_year_n']} ({facts['min_year']})"
assert sum(int(r["n"]) for r in rows) == facts["n_docs"], "field-year counts disagree with facts"
assert len({r["field"] for r in rows}) == facts["n_fields"], "field count disagree"
h = open(f"{B}/index.html", encoding="utf-8").read()
d = json.loads(re.search(r"const EMBEDDED = (\{.*?\});\n", h, re.S).group(1))
assert d["meta"]["n_docs"] == facts["n_docs"], "dashboard meta disagrees"
assert len(d["meta"]["fields"]) == facts["n_fields"], "dashboard fields disagree"
p = open(f"{B}/paper/paper_en.md", encoding="utf-8").read()
a = dict(re.findall(r"<!--K:([a-z0-9_.]+)=([\-0-9.]+)-->", p))
assert int(a["n_docs"]) == facts["n_docs"], "paper anchor disagrees"
assert int(a["n_fields"]) == facts["n_fields"], "paper fields anchor disagrees"
print(f"AC-1 PASS n={facts['n_docs']} fields={facts['n_fields']} min_year_n={facts['min_year_n']} 3-way cross ok")
PY
