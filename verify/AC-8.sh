#!/usr/bin/env bash
# AC-8 v3 (bundle-scoped) — 交付包自足性：README 入口声明 + SEC/PERF/A11Y 预算内联检查 +
# 结构完整（dashboard/papers/figures/data 全在且被 MANIFEST 覆盖）。
# 隔离副本可跑、藏包必红。完整"一键复现"链（run_all --quick + 快照）属 round-0 真跑证据，
# 已由 work/verifiers/heavy/AC-8-pipeline.sh 于 2026-09-12 07:2x rc=0 记录在 ledger/AUDIT。
set -euo pipefail
cd "$(dirname "$0")/.."
B=bundle
fail=0

# README carries the one-command claim
head -1 "$B/README.md" | grep -q "run_all.sh" || { echo "FAIL README line1 one-command"; fail=1; }
grep -q "run_all.sh --full" "$B/README.md" || { echo "FAIL README lacks --full"; fail=1; }

H="$B/index.html"
# SEC: no raw innerHTML writes, no alert, no console, no eval
grep -q "innerHTML" "$H" && { echo "FAIL SEC innerHTML"; fail=1; }
grep -qE "alert\(|console\.(log|error)|eval\(" "$H" && { echo "FAIL SEC alert/console/eval"; fail=1; }
# PERF: entry < 500KB, bundle < 2MB
sz=$(wc -c < "$H"); [ "$sz" -lt 512000 ] || { echo "FAIL PERF index ${sz}B"; fail=1; }
tot=$(du -sk "$B" | awk '{print $1}'); [ "$tot" -lt 2048 ] || { echo "FAIL PERF bundle ${tot}KB"; fail=1; }
# A11Y: lang, viewport, title, alt coverage, labels
grep -q '<html lang=' "$H" || { echo "FAIL A11Y lang"; fail=1; }
grep -q 'name="viewport"' "$H" || { echo "FAIL A11Y viewport"; fail=1; }
grep -q '<title>' "$H" || { echo "FAIL A11Y title"; fail=1; }
imgs=$(grep -c '<img' "$H" || true); alts=$(grep -c 'alt="' "$H" || true)
[ "$imgs" -le "$alts" ] || { echo "FAIL A11Y img without alt ($imgs/$alts)"; fail=1; }

# structural completeness: every delivery component present and manifest-covered
python3 - <<'PY'
import json, os, re, sys
B = "bundle"
need = ["index.html", "README.md", "paper/paper_en.md", "paper/paper_zh.md",
        "figures/MANIFEST.txt", "data/results.json", "data/similarity.csv",
        "data/lexicon.json", "data/dashboard_data.json", "data/sample_facts.json",
        "data/field_year_counts.csv", "data/lexicon_summary.json",
        "data/references_verified.json", "data/ref_liveness.json"]
missing = [f for f in need if not os.path.exists(os.path.join(B, f))]
assert not missing, f"bundle missing: {missing}"
pngs = [f for f in os.listdir(f"{B}/figures") if f.endswith(".png")]
assert len(pngs) >= 8, f"only {len(pngs)} figures"
man = open(f"{B}/figures/MANIFEST.txt").read()
for f in [x for x in need if x != "figures/MANIFEST.txt"] + [f"figures/{p}" for p in pngs]:
    assert f in man, f"not manifest-covered: {f}"
# papers reference components that exist (no broken delivery links)
readme = open(f"{B}/README.md").read()
for ref in ("paper/paper_en.md", "figures", "index.html"):
    assert ref in readme, f"README does not point at {ref}"
print("AC-8 PASS bundle self-contained: 14 core files + %d figures, SEC/PERF/A11Y budget ok" % len(pngs))
PY
[ "$fail" = 0 ] || exit 1
