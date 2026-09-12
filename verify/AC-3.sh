#!/usr/bin/env bash
# AC-3 v2 (bundle-scoped) — 结果完整性 + 方向断言（防掏空/防假数）：
# 关键块齐、CI 有限、boot>=500、跳变全正、事件研究断点模式（后期正、前期近零）
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, math
B = "bundle"
R = json.load(open(f"{B}/data/results.json"))
for k in ("event_study_llmism", "event_study_homogenization", "homogenization_prepost",
          "citation_model", "readability_post", "robustness", "headline",
          "llmism_jump_by_domain", "homog_dynamics"):
    assert k in R, f"missing {k}"
assert R["meta"]["boot"] >= 500, f"boot {R['meta']['boot']} < 500"
assert R["meta"]["n_docs"] >= 120_000
es = {int(y): v for y, v in R["event_study_llmism"].items() if v}
assert len(es) >= 9
pre = [es[y]["coef"] for y in es if y <= 2021]
post = [es[y]["coef"] for y in es if y >= 2023]
assert abs(sum(pre) / len(pre)) < 0.01, "pre-period not flat"
assert sum(post) / len(post) > 0.02, "post-period not elevated"
for y, v in es.items():
    assert all(math.isfinite(v[x]) for x in ("coef", "se", "ci_lo", "ci_hi")), f"non-finite es {y}"
    assert v["ci_hi"] > v["ci_lo"], f"inverted CI {y}"
for dom, j in R["llmism_jump_by_domain"].items():
    assert j["jump"] > 0.05 and j["ci"][0] < j["ci"][1] and j["ci"][0] > 0, f"weak/nonpositive jump {dom}"
assert len(R["robustness"]) >= 3, "need >=3 robustness specs"
assert R["citation_model"]["llmism"]["coef"] > 0, "citation coef flipped"
assert R["homog_dynamics"]["slope_per_year"]["coef"] > 0, "homog slope flipped"
# triangulation: index.html payload + paper anchors must all agree with results
import re
h = open(f"{B}/index.html", encoding="utf-8").read()
d = json.loads(re.search(r"const EMBEDDED = (\{.*?\});\n", h, re.S).group(1))
assert d["headlines"]["hpp"]["coef"] == R["homogenization_prepost"]["coef"], "payload hpp != results"
assert d["headlines"]["citation"]["coef"] == R["citation_model"]["llmism"]["coef"], "payload citation != results"
assert d["meta"]["n_docs"] == R["meta"]["n_docs"], "payload n_docs != results"
p = open(f"{B}/paper/paper_en.md", encoding="utf-8").read()
a = dict(re.findall(r"<!--K:([a-z0-9_.]+)=([\-0-9.]+)-->", p))
for key, path in {"hpp_coef": R["homogenization_prepost"]["coef"],
                  "cit_lin": R["citation_model"]["llmism"]["coef"],
                  "read_coef": R["readability_post"]["coef"],
                  "homog_slope": R["homog_dynamics"]["slope_per_year"]["coef"]}.items():
    assert abs(float(a[key]) - path) < 5e-4, f"{key}: paper {a[key]} vs results {path}"
print(f"AC-3 PASS n={R['meta']['n_docs']} boot={R['meta']['boot']} robust={len(R['robustness'])} dirs ok")
PY
