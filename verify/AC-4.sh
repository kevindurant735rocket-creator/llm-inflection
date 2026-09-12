#!/usr/bin/env bash
# AC-4 v2 (bundle-scoped) — 图完整性 + 全 bundle 哈希清单校验（任意字节篡改即红）
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import hashlib, os
B = "bundle"
F = os.path.join(B, "figures")
manifest = {}
for line in open(os.path.join(F, "MANIFEST.txt")):
    h, rel = line.split()
    manifest[rel] = h
assert len([r for r in manifest if r.startswith("figures/") and r.endswith(".png")]) >= 8, "need >=8 figures in manifest"
have = 0
for rel, h in manifest.items():
    p = os.path.join(B, rel)
    assert os.path.exists(p), f"manifest file missing: {rel}"
    digest = hashlib.sha256(open(p, "rb").read()).hexdigest()
    assert digest == h, f"TAMPERED: {rel}"
    if rel.endswith(".png"):
        assert os.path.getsize(p) > 20_000, f"figure too small: {rel}"
        assert open(p, "rb").read(8)[:4] == b"\x89PNG", f"not a PNG: {rel}"
        have += 1
assert have >= 8
print(f"AC-4 PASS figures={have} manifest={len(manifest)} files all sha256-verified")
PY
