#!/usr/bin/env bash
# AC-7 v3 (bundle-scoped) — 仪表盘三方一致：index.html EMBEDDED == data/dashboard_data.json
# == 由 similarity.csv/results.json 独立重算的关键数字；真起静态服务器 HTTP 200。
# 隔离可跑（无 pipeline 依赖）、藏包必红、掏空 index.html 或 dashboard_data.json 必红。
set -euo pipefail
cd "$(dirname "$0")/.."
B=bundle
python3 - <<'PY'
import json, re, csv
B = "bundle"
h = open(f"{B}/index.html", encoding="utf-8").read()
d = json.loads(re.search(r"const EMBEDDED = (\{.*?\});\n", h, re.S).group(1))
mirror = json.load(open(f"{B}/data/dashboard_data.json"))
assert json.loads(json.dumps(d)) == json.loads(json.dumps(mirror)), "index.html payload != shipped dashboard_data.json"
R = json.load(open(f"{B}/data/results.json"))
sim = list(csv.DictReader(open(f"{B}/data/similarity.csv")))
dom_rows = [r for r in sim if r["level"] == "domain"]
assert len(d["words"]) >= 40, f"only {len(d['words'])} word series"
assert all(len(v) >= 10 for v in list(d["words"].values())[:5]), "short series"
assert len(d["homogenization"]) == len(dom_rows) == len(set((r["domain"], r["year"]) for r in dom_rows)), "hom grid != similarity.csv domain rows"
assert {k for k, v in R["event_study_llmism"].items() if v} == set(d["did_llmism"]), "did_llmism years != results event study"
assert len(d["did_homog"]) >= 11
hl = d["headlines"]
assert abs(hl["hpp"]["coef"] - R["homogenization_prepost"]["coef"]) < 1e-6, "headline hpp != results"
assert abs(hl["jump_max"]["max_domain_jump_val"] - R["headline"]["max_domain_jump_val"]) < 1e-9, "headline jump != results"
assert hl["citation"]["coef"] == R["citation_model"]["llmism"]["coef"], "headline citation != results"
assert d["meta"]["n_docs"] == R["meta"]["n_docs"], "meta n_docs != results"
assert len(h) > 15000, f"dashboard too thin: {len(h)}B"
print(f"AC-7 PASS payload==mirror==recomputed (words={len(d['words'])} hom={len(d['homogenization'])} did={len(d['did_llmism'])})")
PY
PORT=$((20000 + RANDOM % 20000))
while lsof -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; do PORT=$((PORT+1)); done
python3 -m http.server $PORT --bind 127.0.0.1 --directory "$B" >/tmp/ac7_srv.log 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT
code=000
for i in $(seq 1 30); do code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/index.html" || echo 000); [ "$code" = "200" ] && break; sleep 0.2; done
[ "$code" = "200" ] || { echo "dashboard HTTP $code"; exit 1; }
echo "AC-7 PASS http200 cold-static-serve"
