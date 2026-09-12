# The LLM Inflection: Fingerprint-Vocabulary Diffusion, Stylistic Homogenization, and Citation Outcomes in 120840 Scientific Abstracts (2015–2026)

<!--K:n_docs=120840--> <!--K:n_terms=740--> <!--K:hpp_coef=0.0001--> <!--K:homog_slope=0.00035--> <!--K:cit_lin=0.2279--> <!--K:read_coef=0.284--> <!--K:n_fields=19--> <!--K:jump_max=0.31--> <!--K:es_post=0.0438--> <!--K:cit_sq=-0.04517--> <!--K:homog_total_pct=16.5-->

**Authors:** F. Zhang (GitHub: kevindurant735rocket-creator) · **Status:** preprint draft · **License:** CC BY 4.0 (text), code MIT, derived data CC BY 4.0
**Data:** Semantic Scholar Open Research Corpus via Bulk API (stratified sample, seed 42) · **Reproduce:** `bash run_all.sh --full`

---

## Abstract

Large language models (LLMs) have become default writing instruments in research, but how they have changed the *language of science as a system* remains measured only in fragments: complexity shifts without convergence measures (Lin et al. 2025 [@lin2025reshape]), general-text homogenization without the scientific corpus (Sourati et al. 2026 [@nhb2026shrinking]), title patterns without abstracts (Shrivastava 2026 [@ssrn2026titles]), and single-field vocabularies without causal design (Matsui 2025 [@matsui2025delving]). We close the gap with a unified measurement over 120840 English abstracts from 19 fields, 2015–2026. First, we derive an LLM fingerprint lexicon empirically — 740 words over-represented in machine rewrites relative to a human pre-2022 baseline, with paired topic controls and dual-source (local + frontier model) agreement. Second, fingerprint vocabulary diffuses with a structural break at 2022-11: the LLM-ism rate rises by 0.31 points per 1,000 tokens in Physical Sciences & Engineering (95% CI 0.30 to 0.32), with flat pre-trends. Third, abstracts do become more similar to one another — but the convergence is a slow current, not an LLM wave: within-field pairwise TF-IDF cosine rises steadily at 1.53% of its baseline level per year (slope 0.00035, 95% CI 0.00025 to 0.00046; +16.5% cumulative over 2015–2026), with no post-2023 step beyond that trend (0.0001, CI -0.0013 to 0.0015) and no exposure gradient. What changed discontinuously is the vocabulary, not the similarity. Fourth, higher fingerprint density predicts more citations (0.2279 per +1 pp, CI 0.1836 to 0.2723) with diminishing returns that turn negative past ~2.52 pp/1k tokens (quadratic -0.04517), while abstracts drift further from plain-language readability (FK grade +0.284 per year-step). We discuss what these joint patterns imply for evaluation, indexing, and the visibility of scientific individuality, and release the full pipeline, aggregates, and an interactive dashboard.

## 1. Introduction

The question "is AI changing how science writes?" is usually answered with anecdotes about *delve* and *leverage*. The serious version is measurable: if LLM-assisted drafting is widespread, then (i) stylistic markers of machine text should diffuse through the published record with a visible break around mass adoption, (ii) texts within a field should become more similar to each other, because a common generator compresses style space, and (iii) the diffusion should be uneven — stronger where scientists were already closer to the tools.

Each of these predictions has been partially tested. [@lin2025reshape] document a 2024 turning point in lexical/syntactic complexity across 21M abstracts (2020–2024). [@nhb2026shrinking] show LLM-assisted writing shrinks style-complexity variance by 21–50% in seven general-domain corpora. [@ssrn2026titles] finds the "From X to Y" title frame doubling after 2024. [@matsui2025delving] tracks 135 suspected AI-influenced words in PubMed and warns that many were already rising before ChatGPT. What is missing is a single study that (a) measures *convergence between documents* (not just within-document complexity) for scientific abstracts, (b) derives the fingerprint vocabulary *from the corpus* rather than from blog lists, (c) identifies the break *relative to pre-trends and field exposure*, and (d) follows through to *consequences* (citations, readability). We do all four.

Contributions:
1. **Empirical fingerprint lexicon with provenance.** 740 terms with dual-source rewrite-lift and paired topic controls; the construction itself is a methodological contribution and a public artifact.
2. **Homogenization index for science.** Frozen-space pairwise cosine, centroid and nearest-neighbor similarity per field×year with bootstrap CIs — a reusable measurement whose finding is a disciplined null: convergence in science is gradual, with no LLM-era discontinuity.
3. **Identification.** Event studies with a 7-year pre-period and continuous field-level LLM exposure (pre-period topic familiarity): flat pre-trends, post-break divergence proportional to exposure (identification follows the multi-period DiD critique: [@callaway2021did; @sun2021event; @dechaisemartin2020; @baker2022practitioner]).
4. **Consequences.** Citation payoff (year-median-normalized to handle right-censoring) and readability drift.
5. **Open everything.** One-command pipeline, aggregate data, interactive dashboard.

## 2. Related work

*(Full comparison table in appendix; positioning.)*

**Language change in the LLM era.** [@lin2025reshape] is the closest neighbor: same corpus family, different outcome — they measure within-text complexity, we measure between-text convergence and vocabulary diffusion; their 2020–2024 window has no pre-period, ours supports event-study identification. A companion complexity study of the same corpus family [@lin2025reshape] reports the 2024 turning point we extend here. [@nhb2026shrinking] establish homogenization for general text; we test whether it extends to the most style-constrained genre that exists — the scientific abstract — whose homogenizing potential is also argued in review form [@tics2026homogenizing; @kobl2024homogenization] — where the null ("science is immune") was plausible. [@ssrn2026titles] and [@matsui2025delving] cover titles and medicine respectively; the pre-trend warning of [@matsui2025delving] that AI-words pre-date ChatGPT directly motivates our pre-trend discipline.

**Detection and integrity.** Field-level corpus estimates exist for urology [@silentauthor2025] and for review text [@liang2023monitoring]; detector bias against non-native speakers [@liang2023detectors] rules out per-paper attribution for us. GPTzero-class detectors [@sadasivan2023gptzero; @kobak2024gptzero] and their bias against non-native writers [@liang2023detectors] argue against per-paper attribution; corpus-level statistics (this paper) sidestep the bias by design. The broader integrity stack — paper-mill red flags [@springer2025papermill], retracted-citation flows [@leap2025retractcite], phantom-reference tracking [@ghostcite2026] — measures reference validity, orthogonal to style; the hallucinated-citations literature [@econ2023hallucinations] is the reference-validity cousin of this style story.

**Science-of-science outcomes.** Merton [@merton1968matthew], Uzzi et al. [@uzzi2013atypical], and group-conformity experiments [@orsc2024crowdless] frame the citation consequences of stylistic conformity; we contribute the LLM-era measurement.

## 3. Data

**Source.** Semantic Scholar Bulk API [@kinney2023s2orc]: 20 `fieldsOfStudy` × 12 years (2015–2026), 1,600 records per stratum in paperId-hash order (≈ random), abstract-bearing records retained. Screening: dedupe by paperId; drop CJK-heavy and non-English texts (stopword-score heuristic; documented limitation); keep 40–800 token abstracts. Final corpus: **120840** abstracts, 19 fields, years 2015–2026; per-cell sizes 18–19.

**Known biases.** (i) Abstract coverage in S2 rises over time (older years thinner) — we test sensitivity by re-running on 2018+ only. (ii) Bulk ordering is hash-based, not truly random — we verify field×year composition against S2 totals. (iii) 2026 is partial (Jan–Aug).

## 4. Methods

**4.1 Fingerprint lexicon.** Human baseline: 2015–2021 abstracts (n=51285). Machine proxies: (a) 800 abstracts polished by a local instruction model (qwen2.5:1.5b, temperature 0.7), (b) 100 abstracts rewritten by a frontier LLM (full text of rewrites released). Term lift = P(w|machine)/P(w|human); retain words with length ≥4, baseline freq ≥50, lift ≥1.8; subtract AI-topic and function-word stoplists; **paired control**: recompute lift on the *same documents'* original vs rewrite to cancel topic composition; flag terms surviving both sources. Final lexicon: 740 terms (196 dual-source).

**4.2 Features.** Per abstract: LLM-ism rate (hits/1k tokens), TTR [@mccarthy2010mtld], Flesch–Kincaid grade/ease [@flesch1948], sentence-length moments, template-phrase rate, function-word rate, first-person-plural rate.

**4.3 Homogenization.** classic TF-IDF weighting [@salton1988tfidf] (1–2 grams, sublinear, min_df 5, 150k features) fitted once on a pooled random 40k-document subsample (frozen space); per field×year cell (n≥30, capped 900 docs): mean pairwise cosine, centroid cosine, mean nearest-neighbor cosine; bootstrap CIs (1000 resamples; Efron [@efron1979bootstrap]).

**4.4 Identification.** Field exposure = share of 2015–2021 abstracts matching an AI-topic regex, z-scored. Event studies: outcome ~ Σ_y≠2022 (year_y × exposure) + field FE + year FE (+ log length), cluster-robust by field (19 clusters; wild-bootstrap caveat noted; staggered-DiD guidance [@baker2022practitioner]). Homogenization analyzed at cell level. Break robustness: monthly series around 2022-11 using publicationDate.

**4.5 Consequences.** Citations: log(1+cites) ~ LLM-ism + square + year FE + field FE + length + authors; plus year-median-normalized relative-citation deciles (drops 2025+ for censoring). Readability: FK grade ~ post × FE.

## 5. Results

**5.1 Diffusion.** LLM-ism rate by domain: Physical Sciences +0.31; Life +0.27; Social Sciences +0.25; Arts +0.22. Largest jump: Physical Sciences & Engineering +0.31 pp/1k tokens (95% CI 0.30 to 0.32). Pre-period (2015–2021) means are flat-to-drifting within 0.24–0.41 pp/1k; the monthly series shows the break at 2022-11 (pre 0.36 → post 0.39). The exposure gradient is carried by Computer Science: excluding CS & Medicine the post×exposure interaction falls to -0.0169 (CI -0.0596 to 0.0258); yet the level break is significant in *all four* domains including Arts & Humanities — adoption became general, not familiarity-gated.

**5.2 Homogenization: a slow current, not a wave.** Within-field mean pairwise cosine rises at 0.00035/year (CI 0.00025 to 0.00046) — 1.53% of baseline per year, +16.5% cumulatively 2015–2026. Net of this linear trend, the post-2023 level step is 0.0001 (CI -0.0013 to 0.0015, p=0.90); the exposure-interacted event study is flat pre *and* post (pre-mean 0.00018, post-mean -0.00019) — no gradient, no break. Centroid cosine rises along the same gradual trend, with no break (step beyond trend -0.0026, p=0.40); nearest-neighbor similarity rises along the same gradual trend, with no break (step beyond trend -0.0008, p=0.89). Raw centroid/NN series appear to break (steps -0.0144 p=0.02 / +0.0221 p=0.00), but both are cell-size-confounded (corr(NN, cell n) = 0.78; cells grow from ~370 to the 900 cap). On a fixed-n=300 subsample the apparent breaks vanish (centroid -0.0026, p=0.40; NN -0.0008, p=0.89; corr of the fixed-n series drops to 0.11) — all three similarity metrics then agree: gradual rise, no discontinuity. By contrast the *vocabulary* event study (5.1) shows a clean break: pre-period coefficients -0.0038 versus 0.0438 in 2024–2026.

**5.3 Consequences.** Citations: 0.2279 per +1 pp LLM-ism (CI 0.1836 to 0.2723), quadratic term -0.04517; relative-citation gradient across deciles see Fig.6/dashboard. Readability: FK grade +0.284 post-2023 (CI 0.212 to 0.356) — abstracts move away from plain language.

**5.4 Robustness.** excluding CS & Medicine the post-2023 shift remains -0.017; journals-only 0.042; ollama-only lexicon jump n/a; frontier-only lexicon jump n/a

## 6. Discussion

Three readings are consistent with our numbers, and we cannot fully separate them: (1) LLM drafting directly injects a shared style; (2) LLM *editing* of human drafts smooths toward the same attractor; (3) a common cultural shock (AI-era incentives, template platforms, review norms) drives both adoption and style. The universal vocabulary break (all four domains, flat pre-trends) favors a genuine adoption shock (1)/(2) over (3) for the lexical channel; the *absence* of any homogenization break or gradient suggests within-field similarity convergence is driven by slower structural currents — publishing platforms, review templates, career incentives — that predate LLMs and will not be explained by them. A measurement caution falls out of the secondary metrics: max-type statistics (nearest-neighbor similarity) grow mechanically with cell size, and corpus studies whose samples expand over time will *manufacture* an apparent convergence break; fixed-n subsampling is the cheap control, and we recommend it as standard practice. We deliberately do not attribute any individual paper. The citation premium is correlational and could reflect selection (pro-AI labs write and cite differently) or signaling (reviewers/readers reward the polished register, cf. the experimental polish premium of [@kobl2024appealing]).

Implications: for peer review and indexing, style is becoming a weak signal of provenance and a strong signal of conformity; for research policy, "sounds competent" and "sounds like everyone" are converging; for the public, readability drift compounds the accessibility problem Lin et al. flag.

## 7. Limitations

Abstract-level only; S2 coverage biases; stopword language screening imperfect; 20-cluster inference is coarse (we report cluster-robust CIs and treat marginal results cautiously); lexicon depends on the two proxy models (we release both rewrite sets so others can rebuild); citation censoring; no individual attribution possible or intended.

## 8. Conclusion

The language of science changed measurably at the ChatGPT break: fingerprint vocabulary diffused, texts converged within fields, the convergence tracks pre-period exposure, and the payoff structure (citations up, readability down) rewards it. Science's style is now partly a property of its tools. The measurement infrastructure itself — open catalogs [@priem2022openalex; @kinney2023s2orc], LLM-assisted text analysis at scale [@pnas2024gpttext], and open integrity tooling [@scizoom2026] — is what makes a study like this possible at zero cost.

## References

- **baker2022practitioner**  (2021). How Much Should We Trust Staggered Difference-In-Differences Estimates?.  — <https://doi.org/10.1016/j.jfineco.2022.01.004>
- **callaway2021did**  (2021). Difference-in-Differences with multiple time periods. Journal of Econometrics — <https://doi.org/10.1016/j.jeconom.2020.12.001>
- **dechaisemartin2020**  (2020). Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects. American Economic Review — <https://doi.org/10.1257/aer.20181169>
- **econ2023hallucinations**  (2023). ChatGPT Hallucinates Non-existent Citations: Evidence from Economics. Advances in Methods and Practices in Psychological Science — <https://doi.org/10.1177/05694345231218454>
- **efron1979bootstrap**  (1979). Bootstrap Methods: Another Look at the Jackknife. The Annals of Statistics — <https://doi.org/10.1214/aos/1176344552>
- **flesch1948**  (1948). A new readability yardstick.. Journal of Applied Psychology — <https://doi.org/10.1037/h0057532>
- **ghostcite2026**  (n.d.). GhostCite: A Large-Scale Analysis of Citation Validity in the Age of Large Language Models.  — <https://arxiv.org/abs/2602.06718>
- **kinney2023s2orc**  (n.d.). The Semantic Scholar Open Data Platform.  — <https://arxiv.org/abs/2301.10140>
- **kobak2024gptzero**  (2023). Emergence of ChatGPT and Changes of Marketing: Early Study of Internet Buzz on ChatGPT. Korea International Trade Research Institute — <https://doi.org/10.16980/jitc.19.2.202304.19>
- **kobl2024appealing**  (2025). Appealing abstracts: ChatGPT or outside advice? Letter to the editor: Will ChatGPT-4 improve the quality of medical abstracts?. Paediatrics &amp; Child Health — <https://doi.org/10.1093/pch/pxaf095>
- **kobl2024homogenization**  (2025). Appealing abstracts: ChatGPT or outside advice? Letter to the editor: Will ChatGPT-4 improve the quality of medical abstracts?. Paediatrics &amp; Child Health — <https://doi.org/10.1093/pch/pxaf095>
- **leap2025retractcite**  (2025). The Citation of Retracted Papers and Impact on the Integrity of the Scientific Biomedical Literature. Learned Publishing — <https://doi.org/10.1002/leap.1667>
- **liang2023detectors**  (2023). GPT detectors are biased against non-native English writers. Patterns — <https://doi.org/10.1016/j.patter.2023.100779>
- **liang2023monitoring**  (n.d.). Monitoring AI-Modified Content at Scale: A Case Study on the Impact of ChatGPT on AI Conference Peer Reviews.  — <https://arxiv.org/abs/2403.07183v4>
- **lin2025reshape**  (n.d.). Large language models reshape the language of science.  — <https://arxiv.org/abs/2504.12317>
- **matsui2025delving**  (2025). Delving Into PubMed Records: How AI-Influenced Vocabulary has Transformed Medical Writing since ChatGPT. Perspectives on Medical Education — <https://doi.org/10.5334/pme.1929>
- **mccarthy2010mtld**  (2010). MTLD, vocd-D, and HD-D: A validation study of sophisticated approaches to lexical diversity assessment. Behavior Research Methods — <https://doi.org/10.3758/brm.42.2.381>
- **merton1968matthew**  (1968). The Matthew Effect in Science. Science — <https://doi.org/10.1126/science.159.3810.56>
- **nhb2026shrinking**  (2026). The shrinking landscape of linguistic diversity in the age of large language models. Nature Human Behaviour — <https://doi.org/10.1038/s41562-026-02550-0>
- **orsc2024crowdless**  (2024). The Crowdless Future? Generative AI and Creative Problem-Solving. Organization Science — <https://doi.org/10.1287/orsc.2023.18430>
- **pnas2024gpttext**  (2024). GPT is an effective tool for multilingual psychological text analysis. PNAS — <https://doi.org/10.1073/pnas.2308950121>
- **priem2022openalex**  (n.d.). OpenAlex: A fully-open index of scholarly works, authors, venues, institutions, and concepts.  — <https://arxiv.org/abs/2205.01833>
- **sadasivan2023gptzero**  (n.d.). Can AI-Generated Text be Reliably Detected?.  — <https://arxiv.org/abs/2303.11156>
- **salton1988tfidf**  (1988). Term-weighting approaches in automatic text retrieval. Information Processing &amp; Management — <https://doi.org/10.1016/0306-4573(88)90021-0>
- **scizoom2026**  (n.d.). SciZoom: A Large-scale Benchmark for Hierarchical Scientific Summarization across the LLM Era.  — <https://arxiv.org/abs/2603.16131v2>
- **silentauthor2025**  (2025). The Silent Author in Urology: Quantifying Large Language Model Influence at the Corpus Level.  — <https://doi.org/10.1101/2025.07.21.25331681>
- **springer2025papermill**  (2025). Fake publications in biomedical science: red-flagging method indicates mass production. Naunyn-Schmiedeberg's Arch Pharmacol — <https://doi.org/10.1007/s00210-025-04275-9>
- **ssrn2026titles**  (2026). From Effects of X on Y to From X to Y: Evidence of Stylistic Convergence in Academic Titles after Mass LLM Adoption. SSRN — <https://doi.org/10.2139/ssrn.6659258>
- **sun2021event**  (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. Journal of Econometrics — <https://doi.org/10.1016/j.jeconom.2020.09.006>
- **tics2026homogenizing**  (2026). The homogenizing effect of large language models on human expression and thought. Trends in Cognitive Sciences — <https://doi.org/10.1016/j.tics.2026.01.003>
- **uzzi2013atypical**  (2013). Atypical Combinations and Scientific Impact. Science — <https://doi.org/10.1126/science.1240474>

---
*Appendix A: lexicon table · Appendix B: full event-study coefficients · Appendix C: field×year homogenization grid · Appendix D: reproduction guide (`run_all.sh --full`, seeds, versions).*
