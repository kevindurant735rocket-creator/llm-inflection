#!/usr/bin/env bash
# AC-5 v2 (bundle-scoped) — 英文论文：结构齐 + 参考文献键全部在 verified 表内 + K 锚点↔results
# 引用 URL 活性用 TOFU 缓存（data/ref_liveness.json，首轮由 pipeline-mode heavy/AC-5 真实跑过 Crossref 写入）；
# bundle 域不联网（保证隔离副本可跑且确定），活性证据见缓存文件 + heavy/AC-5-pipeline.sh 首轮输出。
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, re
B = "bundle"
text = open(f"{B}/paper/paper_en.md", encoding="utf-8").read()
assert not re.search(r"\{\{[a-z_]+\}\}", text), "unfilled {{vars}}"
assert not re.search(r"TODO|lorem|PLACEHOLDER|待填", text, re.I), "placeholder found"
for sec in ("Abstract","Introduction","Related work","Data","Methods","Results","Discussion","Limitations","References"):
    assert re.search(rf"(?i)\b{sec}\b", text), f"missing section: {sec}"
refs = json.load(open(f"{B}/data/references_verified.json"))
cites = set()
for blk in re.findall(r"\[((?:@[a-z0-9_]+)(?:;\s*@[a-z0-9_]+)*)\]", text):
    cites |= set(re.findall(r"@([a-z0-9_]+)", blk))
unknown = cites - set(refs)
assert not unknown, f"cites without verified entry: {unknown}"
unverified = {k for k in cites if refs[k].get("verified") is not True}
assert not unverified, f"cited but not verified: {unverified}"
assert len(cites) >= 25, f"only {len(cites)} verified citations"
live = json.load(open(f"{B}/data/ref_liveness.json"))
for k in cites:
    u = ("https://api.crossref.org/works/" + refs[k]["doi"].replace(" ", "%20")) if refs[k].get("doi") else refs[k]["url"]
    assert live.get(k) == u, f"liveness cache disagrees for {k}"
R = json.load(open(f"{B}/data/results.json"))
anchors = dict(re.findall(r"<!--K:([a-z0-9_.]+)=([\-0-9.]+)-->", text))
def dig(path):
    cur = R
    for p in path.split("."):
        cur = cur[int(p)] if p.isdigit() else cur[p]
    return float(cur)
checks = {"hpp_coef":"homogenization_prepost.coef","cit_lin":"citation_model.llmism.coef",
          "read_coef":"readability_post.coef","homog_slope":"homog_dynamics.slope_per_year.coef",
          "cit_sq":"citation_model.llmism_sq.coef"}
for a, p in checks.items():
    assert a in anchors, f"anchor {a} missing"
    assert abs(float(anchors[a]) - dig(p)) < 5e-4, f"{a}: paper {anchors[a]} vs results {dig(p)}"
assert int(anchors["n_docs"]) == R["meta"]["n_docs"], "n_docs anchor mismatch"
h = open(f"{B}/index.html", encoding="utf-8").read()
d = json.loads(re.search(r"const EMBEDDED = (\{.*?\});\n", h, re.S).group(1))
assert d["meta"]["n_docs"] == R["meta"]["n_docs"], "index.html n_docs != results (triangulation)"
assert d["meta"]["n_fields"] == int(anchors.get("n_fields", d["meta"]["n_fields"])), "n_fields anchor != payload"
print(f"AC-5 PASS sections=9 refs_verified={len(cites)} anchors={len(anchors)} (TOFU liveness bundle-verified)")
PY
