# 上线三选一（均免费，10 分钟）

## A. GitHub Pages
1. 新建公开仓库（如 `llm-inflection`），把「官网-双击打开」目录内全部文件放到仓库根
2. Settings → Pages → Deploy from branch → `main` / root
3. 打开 `https://<用户名>.github.io/llm-inflection/` 验证首页 200
4. 若仓库名与 robots.txt/sitemap.xml 中 URL 不同，替换这两个文件里的域名即可（只影响 SEO 提示，不影响功能）

## B. Cloudflare Pages / Netlify Drop
直接把「官网-双击打开」整个文件夹拖进去，绑定域名即上线。

## C. 任何静态服务器
`python3 -m http.server 8000 --directory 官网-双击打开` → http://127.0.0.1:8000

上线后建议：① arXiv（cs.DL / stat.AP）上传 paper.pdf；② HN/知乎发「发布长文」；③ sitemap 提交给搜索引擎。
