# The LLM Inflection

**Live site: <https://kevindurant735rocket-creator.github.io/llm-inflection/>**


**An evidence-based test of whether AI is homogenizing how science writes.**

120,840 scientific abstracts, 19 fields, 2015–2026. Claims that "AI is flattening
scientific prose" are everywhere and mostly untested. This measures it with a design
built to be falsified — and reports a null result that survived a control the flattering
version did not.

> **AI rewrote the vocabulary of science. It did not make science sound the same.**

## The four results

**1. Vocabulary — there is a break, and it is sharp.**
An empirically derived LLM fingerprint lexicon of **740 terms** (65-term dual-source
core), built from machine rewrites against a human pre-2022 baseline with paired topic
controls. The fingerprint rate steps up at **2022-11** in all four domains:

| domain | pre-break | post-break | jump per 1k tokens | 95% CI | n pre / post |
|---|---|---|---|---|---|
| Physical Sciences & Engineering | 0.245 | 0.553 | **+0.309** | 0.298–0.320 | 22,731 / 20,401 |
| Life & Health Sciences | 0.306 | 0.576 | +0.270 | 0.254–0.285 | 12,914 / 11,709 |
| Social Sciences | 0.406 | 0.659 | +0.253 | 0.238–0.268 | 12,604 / 18,484 |
| Arts & Humanities | 0.303 | 0.525 | +0.222 | 0.195–0.246 | 2,935 / 6,156 |

Seven pre-trend years are flat — mean pre-period effect **−0.004** versus **+0.044** in
the last three years. The break is not a continuation of an existing trend.

**2. Similarity — no break. This is the null, and it is the paper's main claim.**
Within-field pairwise TF-IDF cosine rises by **1.53% of its baseline level per year**
(+16.5% cumulative, 2015–2026). It is a slow current. There is no 2023 step beyond that
trend: coefficient 0.0001, 95% CI [−0.0013, 0.0015], **p = 0.90**, n = 227 field-year
cells. And there is no exposure gradient.

**3. Consequence for citations — it pays, then it stops paying.**

| term | coefficient | 95% CI | n |
|---|---|---|---|
| fingerprint density | +0.2279 log-citations per +1 pp | 0.1836 – 0.2723 | 120,840 |
| fingerprint density² | −0.0452 | −0.0560 – −0.0344 | 120,840 |

An inverted U. The quadratic term turns the linear term over at **≈2.52 pp per 1,000
tokens** — past that, denser LLM vocabulary is associated with *fewer* citations.

**4. Consequence for readability — one-directional.**
Flesch–Kincaid grade **+0.284** per year-step after 2023 (95% CI 0.212–0.356, n=120,840).
Abstracts got measurably harder to read, with no turning point in sight.

## The control that killed the exciting version

The centroid and nearest-neighbour similarity series initially showed a clean 2023
discontinuity. Both are **max-type statistics**, which means a growing cell
manufactures a jump on its own. On a fixed **n = 300** subsample per cell, both breaks
vanish and all three similarity measures agree: homogenization is gradual.

This is disclosed in the paper rather than reported away, because the fixed-n grid ships
in `bundle/data/similarity.csv` and anyone can check it.

## Real output

Eight machine gates re-verify the entire bundle — corpus facts, lexicon definitions,
direction assertions, a sha256 manifest, citations, and a recomputed dashboard payload:

```console
$ bash verify/run.sh

AC-1 PASS n=120840 fields=19 min_year_n=3913 3-way cross ok
AC-2 PASS terms=740 core=65 dual=196 baseline=51285
AC-3 PASS n=120840 boot=1000 robust=6 dirs ok
AC-4 PASS figures=9 manifest=22 files all sha256-verified
AC-5 PASS sections=9 refs_verified=31 anchors=11 (TOFU liveness bundle-verified)
AC-6 PASS zh_chars=4259 anchors=11 zh==en==results
AC-7 PASS payload==mirror==recomputed (words=191 hom=48 did=11)
AC-7 PASS http200 cold-static-serve
AC-8 PASS bundle self-contained: 14 core files + 9 figures, SEC/PERF/A11Y budget ok
ALL 8 GATES PASS
```

These gates read only files inside `bundle/`. Delete or blank any shipped file and the
corresponding gate goes red — AC-4 sha256-verifies all 22 files. This runs in under
10 seconds on a cold copy, with no network and no dependencies.

## Reproduce

```bash
git clone https://github.com/kevindurant735rocket-creator/llm-inflection
cd llm-inflection

bash verify/run.sh        # 8 gates over the committed bundle — works, no deps, <10s
python3 -m http.server 8000
# http://127.0.0.1:8000/          landing
#                              /paper.html        9-section manuscript
#                              /dashboard.html    interactive, 191 word trends
#                              /figures.html      9 figures
#                              /reproduce.html    the protocol below
```

To re-derive the statistics from the committed aggregates:

```bash
python3 -c "
import json; d=json.load(open('bundle/data/results.json'))
print('docs          ', d['meta']['n_docs'], d['meta']['years'])
print('lexicon terms ', d['meta']['lexicon_terms'], 'boot', d['meta']['boot'])
print('max jump      ', d['headline']['max_domain_jump'], d['headline']['max_domain_jump_val'])
print('homog step    ', 'coef', d['homogenization_prepost']['coef'], 'p', round(d['homogenization_prepost']['p'],3))
print('readability   ', round(d['readability_post']['coef'],5), 'CI', [round(x,4) for x in (d['readability_post']['ci_lo'], d['readability_post']['ci_hi'])])
"
```

Every number on the site is machine-injected from `results.json` through 11 `<!--K:-->`
anchors, triangulated across the data, the dashboard and both manuscripts.

## What this is not

- **This does not measure whether AI wrote any given paper.** It measures lexical
  diffusion in a corpus. A rise in fingerprint-word frequency is not proof of LLM
  authorship for any abstract, and the paper makes no such claim. Do not use this to
  accuse an author.
- **Abstracts only.** No full text, no figures, no methods sections, no supplementary
  material. Whatever AI does to a paper's argument structure is invisible here.
- **English only, from one corpus.** Semantic Scholar Open Research Corpus, stratified
  sample, seed 42. S2's coverage skews toward CS and biomedicine. Stopword-based
  language screening is imperfect. The corpus is not the world's literature.
- **The lexicon depends on the two proxy models used to build it.** 740 terms derived
  from local-model and frontier-model rewrites. Different rewrites would yield a
  different lexicon. Both rewrite sets are released so others can rebuild it — that is
  the mitigation, not a proof of generality.
- **The exposure gradient is carried by Computer Science.** Pre-period LLM exposure
  (topic familiarity) is 3.918 for CS and negative for 15 of 19 fields. The
  identification strategy leans on that one field; dropping CS and its median gives
  −0.017 (p = 0.44), i.e. the gradient largely disappears. The paper says so.
- **Citation outcomes are censored, and correlational.** Citation windows are unequal
  across 2015–2026, recent papers have had less time to accumulate citations, and the
  +0.23 coefficient is observational. It is not "using LLM vocabulary causes citations".
- **20-cluster inference is coarse.** The pre-period exposure measure has 20 clusters;
  marginal results should be treated cautiously.
- **`run_all.sh` is not in this repository.** `reproduce.html` and `bundle/README.md`
  reference a one-command full pipeline (`bash run_all.sh --full`, ~13 min, download →
  prep → features → similarity → stats → figures → papers → bundle). That script and the
  `pipeline/` tree are not committed. **What ships here is verification of a frozen
  bundle, not the ability to rebuild it from raw data.**
- **It is a preprint**, not peer-reviewed. `paper.html` / `paper.pdf` are drafts.

## Layout

```
verify/run.sh          the 8 gates (AC-1..AC-8) — all must print PASS
bundle/                the shippable, self-contained, cold-verifiable unit
  data/results.json    every regression output, bootstrap = 1000
  data/similarity.csv  field x domain x year grid, incl. fixed n=300 control columns
  data/lexicon.json    740 terms with per-term lift and definitions
  data/ref_liveness.json   31 Crossref-verified URLs (TOFU cache)
  figures/fig1..fig9.png   + MANIFEST.txt (sha256 over 22 files)
index.html             bilingual landing page
paper.html / paper.pdf / paper_zh.html / paper_zh.pdf
dashboard.html         interactive, single file, zero dependency
figures.html, insights.html, reproduce.html
DEPLOY.md              GitHub Pages / Cloudflare / Netlify / static server
```

Deployment is drag-and-drop: GitHub Pages serves the repository root as-is, or drop the
folder onto Cloudflare Pages or Netlify.

## Data, ethics, license

Stratified public metadata from the Semantic Scholar Open Research Corpus. No personal
data, no paid APIs, no per-paper attribution — corpus-level statistics only.

- **Code: MIT** — see [`LICENSE`](LICENSE).
- **Text and derived aggregates: CC BY 4.0.**
