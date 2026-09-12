#!/usr/bin/env bash
# AC-6 v2 (bundle-scoped) — 中文稿：结构齐 + 汉字>=4000 + K 锚点与英文同源且↔results
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, re
B = "bundle"
zh = open(f"{B}/paper/paper_zh.md", encoding="utf-8").read()
en = open(f"{B}/paper/paper_en.md", encoding="utf-8").read()
assert not re.search(r"\{\{[a-z_]+\}\}", zh), "unfilled {{vars}} in zh"
assert not re.search(r"TODO|lorem|PLACEHOLDER|待填", zh, re.I), "placeholder found"
for sec in ("摘要", "引言", "数据", "方法", "结果", "讨论", "局限", "参考"):
    assert sec in zh, f"missing zh section: {sec}"
n_cjk = len(re.findall(r"[一-鿿]", zh))
assert n_cjk >= 4000, f"zh body only {n_cjk} chars"
za = dict(re.findall(r"<!--K:([a-z0-9_.]+)=([\-0-9.]+)-->", zh))
ea = dict(re.findall(r"<!--K:([a-z0-9_.]+)=([\-0-9.]+)-->", en))
assert len(za) >= 8, f"zh anchors only {len(za)}"
R = json.load(open(f"{B}/data/results.json"))
def dig(path):
    cur = R
    for p in path.split("."):
        cur = cur[int(p)] if p.isdigit() else cur[p]
    return float(cur)
mapping = {"hpp_coef":"homogenization_prepost.coef","cit_lin":"citation_model.llmism.coef",
           "read_coef":"readability_post.coef","homog_slope":"homog_dynamics.slope_per_year.coef",
           "cit_sq":"citation_model.llmism_sq.coef"}
for k, p in mapping.items():
    assert k in za and k in ea, f"anchor {k} missing in zh or en"
    assert abs(float(za[k]) - dig(p)) < 5e-4, f"zh {k}: {za[k]} vs results {dig(p)}"
    assert abs(float(za[k]) - float(ea[k])) < 5e-4, f"zh/en anchor disagree on {k}"
assert int(za["n_docs"]) == int(ea["n_docs"]) == R["meta"]["n_docs"], "n_docs zh/en/results disagree"
h = open(f"{B}/index.html", encoding="utf-8").read()
d = json.loads(re.search(r"const EMBEDDED = (\{.*?\});\n", h, re.S).group(1))
assert d["meta"]["n_docs"] == R["meta"]["n_docs"], "index.html n_docs != results (triangulation)"
assert d["meta"]["n_fields"] == int(ea["n_fields"]) == int(za["n_fields"]), "n_fields anchor != payload"
print(f"AC-6 PASS zh_chars={n_cjk} anchors={len(za)} zh==en==results")
PY
