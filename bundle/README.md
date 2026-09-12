`bash run_all.sh --full` — one command reproduces everything in this repo, from raw download to papers, figures and dashboard.

# The LLM Inflection — how AI changed the language of science

A reproducible study of **19 fields × 12 years, 120,840 English abstracts**: does the mass adoption of LLM writing tools leave a measurable fingerprint in scientific abstracts, do abstracts converge stylistically, and does it pay off in citations?

## Findings (paper/paper_en.md · paper/paper_zh.md)
1. An **empirical LLM fingerprint lexicon** (740 terms, 65-term dual-source core) derived from dual-source machine rewrites vs a human baseline with paired topic controls — not copied from blog lists.
2. Fingerprint vocabulary **diffuses with a structural break at 2022-11**: significant level jumps in all four domains (max +0.31 pp/1k tokens, Physical Sciences), seven flat pre-trend years, and a post-break exposure gradient carried mainly by Computer Science.
3. Abstracts **do converge — but gradually**: within-field pairwise TF-IDF cosine rises ~1.5%/yr (+16% cumulative 2015–2026) with **no 2023 step beyond the linear trend (p=0.90) and no exposure gradient**. Raw centroid/nearest-neighbor series look like they break, but both are cell-size-confounded (max-type statistics); on a fixed n=300 subsample the breaks vanish — all three similarity measures then agree: homogenization is a slow current, not an LLM wave; the discontinuity is lexical.
4. **Consequences**: fingerprint density predicts more citations (+0.23 log-points per pp, inverted-U turning over at ~2.5 pp/1k) and *worse* plain-language readability (FK +0.28 grade post-2023).

## Layout
| path | what |
|---|---|
| `run_all.sh` | one-command pipeline (`--quick` skips re-download) |
| `pipeline/` | s2_download → 20_prep → 30_features → 40_similarity → 50_stats → 60_figures → 70_agg_for_dash → 85_build_paper → 90_bundle |
| `dashboard.html` | interactive, single-file, zero-dependency (also the ship-ready platform seed) |
| `paper/` | EN + ZH manuscripts, every number machine-injected with `<!--K:-->` anchors |
| `work/` | spec, plan, assumptions, verifiers (AC-1..8, SEC/PERF/A11Y/E2E), gates, artifacts |
| `outputs/science-language-shift/` | the delivery bundle (figures, dashboard, papers) |
| `data/` | raw sample (regenerate; large files git-ignored) |

## Bundle & verification
The delivery bundle `outputs/science-language-shift/` is **self-contained and cold-verifiable**: `index.html` (dashboard), `README.md`, `paper/paper_{en,zh}.md`, `figures/*.png` + `figures/MANIFEST.txt`, and `data/` (results, similarity grid incl. fixed-n columns, lexicon, payload mirror, corpus facts, verified references + TOFU liveness cache). `pipeline/90_bundle.py` assembles it and writes a sha256 manifest over every file.

Verify from a cold copy (only the bundle + `work/verifiers/` needed, each gate < 1 s):
`bash work/verifiers/AC-1.sh` … `AC-8.sh`. The gates are bundle-scoped and mutation-sensitive: hide the bundle → red; blank any shipped file → the gates that depend on it go red (AC-4 sha256-verifies the whole manifest).
The heavy full-pipeline re-runs (download→prep→features→stats→figures, ~13 min) live in `work/verifiers/heavy/AC-*-pipeline.sh` and were run green at release time as the round-0 reproduction evidence.

## Data & ethics
Stratified public metadata from Semantic Scholar (CC BY aggregates). No personal data, no paid APIs, no per-paper attribution — corpus-level statistics only. License: code MIT, text & aggregates CC BY 4.0.
