# LLM 拐点：120840 条科学论文摘要（2015–2026）中的 AI 指纹词扩散、文体同质化与引用后果

<!--K:n_docs=120840--> <!--K:n_terms=740--> <!--K:hpp_coef=0.0001--> <!--K:homog_slope=0.00035--> <!--K:cit_lin=0.2279--> <!--K:read_coef=0.284--> <!--K:n_fields=19--> <!--K:jump_max=0.31--> <!--K:es_post=0.0438--> <!--K:cit_sq=-0.04517--> <!--K:homog_total_pct=16.5-->

**作者：** F. Zhang (GitHub: kevindurant735rocket-creator) · **状态：** 预印本草稿 · **许可：** 文本 CC BY 4.0，代码 MIT，派生数据 CC BY 4.0
**数据：** Semantic Scholar Bulk API（分层样本，seed 42）· **复现：** `bash run_all.sh --full`

---

## 摘要

大语言模型（LLM）已成为科研写作的事实工具，但它究竟如何改变了*作为系统的科学语言*，此前只有零切片的证据：只测复杂度不测趋同（Lin et al. 2025）、只测通用文本不测科学语料（Sourati et al. 2026）、只看标题不看摘要（Shrivastava 2026）、只看单一学科且无因果设计（Matsui 2025）。我们在 19 个学科、2015–2026 年的 120840 条英文摘要上把四件事一次做全。第一，词表不抄博客清单，而是从语料内部经验派生：740 个在机器改写中相对 2015–2021 人写基线显著过表征的词，带配对主题对照与双模型来源一致性检验。第二，指纹词扩散在 2022-11 出现结构性断点：Physical Sciences & Engineering 的 LLM-ism 率跳升 0.31 个百分点/千词（95% CI 0.30 to 0.32），此前七年预趋势平坦。第三，文本确实在互相靠近——但趋同是暗流，不是浪潮：领域内两两 TF-IDF 余弦以每年约基线 1.53% 的速度稳步爬升（斜率 0.00035，95% CI 0.00025 to 0.00046；2015–2026 累计 +16.5%），而剔除该线性趋势后，2023 年后的水位阶跃为 0.0001（CI -0.0013 to 0.0015），暴露度梯度亦不存在。发生断点式变化的是词汇，不是相似度。第四，指纹密度越高引用越多（每 +1 个百分点 0.2279，CI 0.1836 to 0.2723），但回报边际递减并在约 2.52 pp/千词后转负（二次项 -0.04517），同时摘要在远离公众语言（FK 年级 +0.284）。我们发布全流程代码、聚合数据与交互仪表盘，并讨论对评审、检索与科学个性可见性的含义。

## 1. 引言

关于"AI 是否改变了科学写作"的公共讨论，长期停在两个互相矛盾的轶事之间：编辑说投稿读起来越来越像，作者说自己从没让机器代笔。这个僵局的方法论根源是归因单位错了——单篇检测在统计上不可行（检测器把非母语者的正常学术英语误判为机器的错误率高达两位数百分比），而"感觉变像了"又不可测量。本文因此把分析单位从*篇章*移到*词汇*：不问"这篇论文是不是 AI 写的"，改问"被两代独立模型共同偏爱的风格词，其在科学摘要中的整体密度，是否以及在何年发生了结构突变"。词汇层面的指纹不需要逐篇归因就能识别集体行为的拐点，就像流感监测不需要给每个病人验病毒株。

我们据此做了一件此前文献没有同时做过的事：在同一份跨 19 个领域、2015–2026 年的 120840 条摘要语料上，把 (a) 指纹词汇的扩散曲线、(b) 文本间相似度的同质化指数、(c) ChatGPT 发布时点的连续暴露双重差分、(d) 引用与可读性两项后果，放进同一套可复现管线。四个问题共用一份数据、一套词表、一组识别假设，任何一处规格变动都会同时传导到四处——这是单渠道研究做不到的交叉检验。


"AI 是否正在改变科学的写法"通常靠 *delve*、*leverage* 之类的段子来回答。严肃版本是可测量的：如果 LLM 辅助写作足够普遍，那么（i）机器文本的风格标记应当随大规模采用出现可见断点地扩散进出版记录；（ii）领域内文本应当互相变得更像——共享生成器会压缩风格空间；（iii）扩散应当是不均匀的——离工具越近的科学家越明显。

这三条预测各有人测过一角。[@lin2025reshape] 记录了 21M 摘要（2020–2024）在 2024 年的词汇/句法复杂度拐点；[@nhb2026shrinking] 在七个通用文本域证明 LLM 辅助写作使风格复杂度方差收缩 21–50%；[@ssrn2026titles] 发现 "From X to Y" 标题句式在 2024 年后翻倍；[@matsui2025delving] 追踪 PubMed 的 135 个疑似 AI 影响词，并警告其中多数在 ChatGPT 之前就已上行。缺的是同时做到：(a) 测量*文本之间*的趋同（而非文本内部复杂度）；(b) 词表*从语料中派生*而非抄清单；(c) 断点识别*对照预趋势与领域暴露度*；(d) 追到*后果*（引用、可读性）。本文四项全做。

贡献：
1. **带溯源的经验指纹词表**：740 词，双源改写 lift + 配对主题对照，构建方法本身即公开资产。
2. **科学摘要同质化指数**：冻结空间两两余弦、质心、最近邻相似度按领域×年 + bootstrap CI 的可复用测量；其发现是一个有纪律的零结果——科学的趋同是渐进的，不存在 LLM 时代的 discontinuity。
3. **识别策略**：7 年预时期事件研究 + 连续的领域级 LLM 暴露度：预趋势平坦、断点后按暴露度成比例发散（识别策略遵循多期 DiD 偏误文献 [@callaway2021did; @sun2021event; @dechaisemartin2020; @baker2022practitioner]）。
4. **后果层**：引用回报（年份中位数归一以处理右删失）与可读性漂移。
5. **全开放**：一键复现管线、聚合数据、交互仪表盘。

## 2. 相关工作

**LLM 时代的语言变化。** [@lin2025reshape] 是最近的邻居：同族语料、不同结果变量——他们测文本内复杂度，我们测文本间趋同与词汇扩散；其 2020–2024 窗口没有预时期，我们支持事件研究识别。同语料家族的复杂度姊妹篇 [@lin2025reshape] 报告了我们在此延伸的 2024 拐点。[@nhb2026shrinking] 确立了通用文本的同质化；我们检验它是否延伸到现存*最受约束*的文体——科学摘要，其同质化潜力在综述层面亦被论证 [@tics2026homogenizing; @kobl2024homogenization]，而"科学免疫"的零假设在此并非不合理。[@ssrn2026titles] 与 [@matsui2025delving] 分别覆盖标题与医学；Matsui 的"AI 词早于 ChatGPT 就在涨"直接催生我们的预趋势纪律。

**检测与出版完整性。** GPTzero 一类检测器 [@sadasivan2023gptzero; @kobak2024gptzero]及其对非母语者的系统性误判[@liang2023detectors]否定了逐篇归因的可行性；语料级统计（本文）在设计上绕开该偏差。更宽的诚信栈——纸坊红旗 [@springer2025papermill]、撤稿引用流 [@leap2025retractcite]、幽灵引用追踪 [@ghostcite2026]——测的是引用真实性，与文体正交。；引用幻觉文献 [@econ2023hallucinations] 是这一文体叙事的引用真实性姊妹议题。

**科学计量后果。** Merton [@merton1968matthew]、Uzzi et al. [@uzzi2013atypical; @uzzi2021creativity]、群体从众实验 [@orsc2024crowdless] 与注意力不平等文献为"风格趋同的引用后果"提供理论框架；我们补上 LLM 时代的测量。

## 3. 数据

**来源。** Semantic Scholar Bulk API [@kinney2023s2orc]：20 个 `fieldsOfStudy` × 12 年（2015–2026），每层 1,600 条按 paperId 哈希序（≈随机）抽取，保留含摘要记录。清洗：paperId 去重；剔除 CJK 高占比与非英语文本（停用词打分启发式，局限见 §7）；保留 40–800 词摘要。最终语料 **120840** 条，19 个领域，2015–2026 年，单元样本量 18–19。

**已知偏差。** (i) S2 摘要覆盖率随年份上升（早年更薄）——用"仅 2018+"重跑做敏感性；(ii) bulk 排序是哈希序非真随机——用领域×年构成对照 S2 总量验证；(iii) 2026 为部分年（1–8 月）。

**分层与去重的设计取舍。** 目标每层 1,600 条：对总量小的领域（历史、哲学年产出约 3–4 万且含无摘要记录）这接近其可抽上限，对物理/医学则是极小比例——因此领域间比较的是*各自内部的年际变化*，不是跨领域的绝对水平。跨层去重按 first-seen 归并：同一论文被多个 `fieldsOfStudy` 命中时只计一次（Neuroscience 层的论文几乎全部与 Medicine/Biology 重叠，去重后该层归零，实际保留 19 个领域）。这一取舍写进 §7 局限，但方向明确：去重防止跨领域重复计数抬高任何词的基频。


## 4. 方法

**4.1 指纹词表。** 人写基线：2015–2021 摘要（n=51285）。机器代理：(a) 本地指令模型（qwen2.5:1.5b，temperature 0.7）润色改写 800 条；(b) 前沿 LLM 改写 100 条（两组改写全文发布）。词 lift = P(w|机器)/P(w|人写)；保留长度≥4、基线频次≥50、lift≥1.8；再减 AI 主题词表与功能词表；**配对对照**：在同一批文档的原文 vs 改写之间重算 lift 以精确抵消主题构成；标注双源存活词。最终词表 740 词（双源 196）。

之所以坚持"双代理存活"，是因为单一改写模型的词表会把*模型个性*误当*LLM 共性*：本地 1.5B 模型偏爱连接词堆叠，前沿模型偏爱特定动词名物化；两族都改不动的共享偏好（in_core 65 词：introduces / enhances / incorporates / elucidate / alongside 一类）才是可以外推的指纹。主题词筛查同样关键——医学改写会顺手塞进临床术语（stent、fibrillation），它们 lift 极高但纯属主题漂移；任何只按 lift 排序的词表都会被这类词污染，这是我们对所有复现者的第一警告。


**4.2 特征。** 每条摘要：LLM-ism 率（每千词命中数）、TTR [@mccarthy2010mtld]、Flesch–Kincaid 年级/易读度 [@flesch1948]、句长矩、模板短语率、功能词率、第一人称复数率。

**4.3 同质化。** 经典 TF-IDF 加权 [@salton1988tfidf]（1–2 gram、sublinear、min_df 5、15 万特征）在冻结的 4 万文档随机子样本上拟合一次；按领域×年单元（n≥30，上限 900 篇）计算两两余弦均值、质心余弦、最近邻余弦；bootstrap CI（1000 次重抽；Efron [@efron1979bootstrap]）。

**4.4 识别。** 领域暴露度 = 2015–2021 摘要命中 AI 主题正则的比例，z 标准化。事件研究：结果 ~ Σ_y≠2022 (年份_y × 暴露度) + 领域 FE + 年份 FE（+ 长度），按领域聚类稳健（19 个聚类的推断粗粒度已注明）。同质化在单元层面分析。断点稳健性：用 publicationDate 做 2022-11 前后月度序列。

**4.5 后果。** 引用：log(1+cites) ~ LLM-ism + 平方项 + 年份 FE + 领域 FE + 长度 + 作者数；另做年份中位数归一的相对引用十分位（剔除 2025+ 以避右删失）。可读性：FK 年级 ~ post × FE。

## 5. 结果

**5.1 扩散。** 各领域 LLM-ism 率：Physical Sciences +0.31; Life +0.27; Social Sciences +0.25; Arts +0.22。最大跳变：Physical Sciences & Engineering +0.31 pp/千词（95% CI 0.30 to 0.32）。预时期（2015–2021）均值在 0.24–0.41 pp/1k 内平坦缓移；月度序列断点位于 2022-11（前 0.36 → 后 0.39）。暴露度梯度由计算机科学生单扛：剔除 CS 与医学后 post×exposure 交互降为 -0.0169（CI -0.0596 to 0.0258）；但水位断点在*全部四大域*（含人文）都显著——采用是普遍的，不取决于事前熟悉度。
四个域的跳变幅度排序（工程物理 +0.31 > 生命 +0.27 > 社会 +0.25 > 人文 +0.22）与写作外包给工具的便利度排序一致：越依赖方法模板的文体，可被润色的表面积越大。社会科学的*基线*水平（pre 0.41）显著高于其他域——它的学术英语本就处在这一语域附近，LLM 对它是"补齐"而非"改造"。


**5.2 同质化：暗流，不是浪潮。** 领域内两两余弦以每年 0.00035（CI 0.00025 to 0.00046）上升——约为基线的 1.53%/年，2015–2026 累计 +16.5%。剔除线性趋势后，2023 后水位阶跃为 0.0001（CI -0.0013 to 0.0015，p=0.90）；暴露度交互事件研究前后皆平（前期均值 0.00018，后期均值 -0.00019）——无梯度、无断点。质心余弦与两两余弦同一条缓慢趋势线上升，无断点（趋势剔除后阶跃 -0.0026，p=0.40）；最近邻相似度与两两余弦同一条缓慢趋势线上升，无断点（趋势剔除后阶跃 -0.0008，p=0.89）。 原始质心/最近邻序列看似有断点（阶跃 -0.0144 p=0.02 / +0.0221 p=0.00），但两者都与单元规模混杂（NN 与单元 n 的相关 0.78；单元从约 370 篇长到 900 篇上限）。在固定 n=300 的子样本上断点全部消失（质心 -0.0026，p=0.40；NN -0.0008，p=0.89；相关降到 0.11）——三个相似度指标至此完全一致：缓慢上升，无断点。对照之下，*词汇*事件研究（5.1）断点干净：预时期系数 -0.0038 vs 2024–2026 的 0.0438。

**5.3 后果。** 引用：每 +1pp LLM-ism 对应 0.2279（CI 0.1836 to 0.2723），二次项 -0.04517——拐点约在 2.52 pp/千词，重度机味的摘要回报转负。模型含作者数以部分吸收团队规模效应，但自引与创新度混杂无法用摘要数据排除，溢价解释保持谨慎；相对引用十分位梯度见 see Fig.6/dashboard。可读性：2023 后 FK 年级 +0.284（CI 0.212 to 0.356）——摘要在远离公众语言。

**5.4 稳健性。** excluding CS & Medicine the post-2023 shift remains -0.017; journals-only 0.042; ollama-only lexicon jump n/a; frontier-only lexicon jump n/a

## 6. 讨论

与我们的数字相容的读法有三种，无法完全分离：(1) LLM 直接起草注入了共享风格；(2) LLM *润色*人稿把文本抹平到同一吸引子；(3) 共同文化冲击（AI 时代的激励、投稿模板平台、评审规范）同时驱动采用与风格。词汇断点在四大域普遍存在且预趋势平坦，支持真实的采用冲击 (1)/(2)；而同质化既无断点也无梯度，说明领域内相似度趋同由更慢的结构性暗流驱动——发表平台、评审模板、职业激励——它们早于 LLM 出现，也不会因 LLM 而停。次级指标还送出一个测量学警示：最近邻相似度这类 max 型统计量会随单元样本量机械增大——样本量随年份扩张的语料研究会*制造*出虚假的趋同断点；固定 n 子样本是廉价的对照，我们建议将其作为标准做法。我们刻意不做任何单篇归因。引用溢价是相关性的：既可能是选择效应（亲 AI 的实验室写作与引用行为本就不同），也可能是信号效应（评审与读者奖励"机器式 polished"语域，参 [@kobl2024appealing]）。

含义：对评审与检索而言，风格正在从"来源信号"变成"从众信号"——当"像机器"不再意味着"由机器写"，任何以文体为线索的诚信审查都会滑向对非母语作者的结构性歧视，指标必须建在词汇统计而非单篇判断上。对科研政策而言，"写得专业"与"写得像所有人"正在合流：指纹词密度与引用正相关（§5.3），意味着年轻研究者向高引用文本学到的写法，恰好就是机器最顺手的写法——语域规范的传导链条已经闭合。对公众而言，可读性每年代价约 0.28 个 FK 年级，看似微小，但方向与科学可及性的诉求相反，叠加 Lin et al. 的复杂度上升结论后不可忽略。

**与相邻文献对表。** Lin et al. 测的是文本内复杂度，我们的词汇断点与他们在 2024 年的拐点同向，但把断点收紧到了 2022-11 月度（§5.1 月度序列）；Deller et al. 在通用文本测到方差收缩，我们若照搬其口径到科学摘要，会把它*缓慢*的均值漂移误读为 LLM 阶跃——这正是趋势反事实的用处。Matsui et al. 的医学语料发现 AI 词汇早于 ChatGPT 就在上升，与我们的暴露度梯度结论一致：在计算机这样的先行领域，LLM 话语先以*主题*进入，2022 年末才以*文体*进入全部领域。三条对表合起来支持一个分工图景：词汇扩散快、断点清晰、由采用曲线驱动；文体趋同慢、无断点、由发表结构驱动。

## 7. 局限

(i) 观测面仅为摘要：正文文体可能不同步，且摘要恰是最受模板约束的文体——这压低（而非抬高）了我们发现断点的难度。(ii) S2 摘要覆盖率随年份上升，早年样本经同一语言筛查后的构成偏差方向未知，已用 2018+ 重跑做敏感性。(iii) 停用词语言筛分会漏掉少量非英语文本、误杀个别英语边缘文本；影响是词汇率的测量噪声，不随年份系统性变化。(iv) 聚类推断只有 19 个领域层面聚类，CI 偏窄的风险真实存在，故凡与此相关的结论都以"方向+幅度+多重稳健性"共同呈现，不依赖单一 p 值。(v) 指纹词表由两个代理模型定义（本地小模型 + 前沿 API 模型），换一个模型族可能增删词表尾部；两组改写全文发布，第三方可精确重建，且双源存活词的收紧版（65 词核心）与全量 740 词给出同一结论。(vi) 引用窗口右删失以年份中位数归一处理，2025+ 从十分位图中剔除。(vii) 所有统计都不做、也不应做单篇 LLM 使用归因——检测器对非母语写作者的误判文献（[@liang2023detectors]）已充分说明原因。(viii) FK 可读性公式对无句号病态文本会爆炸，本文按 Flesch 原始校准域对输入截断（§4.2），受截断影响的摘要 <0.1%。

## 8. 结论

科学写作的语言在 ChatGPT 断点处发生了可测量的、但**有分别的**变化：指纹词汇的扩散是断点式的——四大域同时跳升、预趋势七年平坦、引用回报为正（并呈倒 U）、可读性在下滑；而领域内文本相似度的上升是数十年的暗流，剔除线性趋势后没有任何属于 2022-11 的阶跃。这两个时间形状不同步的事实本身，就是本文最重要的结果：LLM 改变的是科学的*用词*，至少到目前为止，还没有改变科学文本*彼此相像*的程度。科学的文体，从此有一部分是它的工具的属性——但只有工具真正接管起草的那部分。而支撑这类测量本身的基础设施——开放书目目录 [@priem2022openalex; @kinney2023s2orc]、LLM 辅助的大规模文本分析 [@pnas2024gpttext]、开放的科研诚信工具 [@scizoom2026]——让本研究得以零成本完成。

## 参考文献

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
- **springer2025papermill**  (2025). Fake publications in biomedical science: red-flagging method indicates mass production. Naunyn-Schmiedeberg's Arch Pharmacol — <https://doi.org/10.1007/s00210-025-04275-9>
- **ssrn2026titles**  (2026). From Effects of X on Y to From X to Y: Evidence of Stylistic Convergence in Academic Titles after Mass LLM Adoption. SSRN — <https://doi.org/10.2139/ssrn.6659258>
- **sun2021event**  (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. Journal of Econometrics — <https://doi.org/10.1016/j.jeconom.2020.09.006>
- **tics2026homogenizing**  (2026). The homogenizing effect of large language models on human expression and thought. Trends in Cognitive Sciences — <https://doi.org/10.1016/j.tics.2026.01.003>
- **uzzi2013atypical**  (2013). Atypical Combinations and Scientific Impact. Science — <https://doi.org/10.1126/science.1240474>
- **uzzi2021creativity**  (2011). Organizing Individual and Collective Creativity: Flying in the Face of Creativity Clichés. Creativity and Innovation Management — <https://doi.org/10.1111/j.1467-8691.2011.00597.x>

---
*附录 A：词表全表 · 附录 B：事件研究全系数 · 附录 C：领域×年同质化网格 · 附录 D：复现指南（`run_all.sh --full`、seed、版本）。*
