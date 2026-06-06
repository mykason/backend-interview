---
name: site-content-sync
description: 自动扫描 backend-interview 项目所有内容 Markdown，更新 README.md、index.md 和 GitHub Pages 首页展示，并重点规避本次修复过的 Pages 旧构建、首页卡片缺失、Liquid/Jekyll 构建问题。
argument-hint: "[更新说明或新增内容范围]"
---

# Site Content Sync

用于维护 `backend-interview` 知识库内容与首页展示。执行本 Skill 时，自动读取项目中所有内容目录下的 `.md` 文件，更新 `README.md`、`index.md`，并验证 GitHub Pages 构建结果。

## 适用场景

- 用户说“更新知识库目录 / 同步 README 和首页 / 刷新 GitHub Pages 展示”。
- 用户新增、移动、删除了 Markdown 知识内容后，需要同步入口。
- 用户要求检查线上 GitHub Pages 为什么没有展示新增卡片或新增文章。
- 用户提到 LeetCode、面试指南、Agent、后端知识等首页分类展示异常。

## 必须读取的文件

执行时先读取当前项目状态，不要依赖记忆：

1. 所有内容 Markdown：
   - `backend/**/*.md`
   - `agent/**/*.md`
   - `guide/**/*.md`
   - `leetcode/**/*.md`
   - 根目录必要 Markdown：`README.md`、`index.md`
2. 站点配置与布局：
   - `_config.yml`
   - `_layouts/default.html`
   - `_layouts/page.html`
   - `assets/css/style.scss`
3. 如果需要验证构建产物，再读取：
   - `_site/index.html`
   - `_site/assets/css/style.css`

跳过以下路径：

- `_site/**/*.md`
- `vendor/**`
- `.bundle/**`
- `.jekyll-cache/**`
- `node_modules/**`
- `.git/**`
- `.claude/**`，除非用户明确要求维护 Skill

## 执行步骤

### 1. 扫描 Markdown 内容

- 使用 Glob/Grep/Read 读取所有内容目录的 `.md` 文件。
- 读取每个页面 front matter：`title`、`layout`、`permalink`、`category`、`subcategory`。
- 如果页面没有 `title`，优先从一级标题 `# ...` 推断。
- 不要把 `_site` 里的生成文件当作内容来源。

### 2. 更新 README.md

保持 README 的作用是项目总览和目录索引。

- 确保 README 中列出所有内容页面。
- 链接使用源文件路径，例如：

  ```markdown
  - [Hot 100](leetcode/hot100.md)
  ```

- 如果新增分类，更新“在线目录”和“项目结构”。
- 不要把 `_site` 路径写进 README。
- 不要删除作者、许可证、本地预览等基础信息，除非用户明确要求。

### 3. 更新 index.md

保持 `index.md` 是 GitHub Pages 首页入口。

- 链接必须使用 Jekyll Liquid 的 `relative_url`，例如：

  ```html
  <li><a href="{{ '/leetcode/hot100' | relative_url }}">Hot 100</a></li>
  ```

- 不要写死完整线上 URL。
- 不要写成 `.md` 后缀链接。
- 新分类优先放到合适的现有区域。
- 避免重复添加同一页面链接。

首页结构必须保持两列布局：

```html
<div class="home-outline">
  <div class="category-section">
    <!-- 左侧：后端知识等大块内容 -->
  </div>

  <div class="side-sections">
    <div class="category-section">LeetCode</div>
    <div class="category-section">Agent 开发</div>
    <div class="category-section">面试指南</div>
  </div>
</div>
```

重点：`.home-outline` 的直接子元素只应有两类：左侧主内容卡片、右侧 `.side-sections` 卡片组。不要把 LeetCode、Agent、面试指南作为多个直接子元素平铺在 `.home-outline` 下，否则 GitHub Pages 首页会出现卡片换行、下沉或看似未展示。

### 4. 检查样式

确认 `assets/css/style.scss` 至少包含：

```scss
.home-outline {
    display: grid;
    grid-template-columns: minmax(0, 1.4fr) minmax(260px, 0.8fr);
    gap: 24px;
    align-items: start;
}

@media (max-width: 768px) {
    .home-outline {
        display: block;
    }
}
```

如果本地页面正常但 GitHub Pages 不正常，必须检查线上 CSS 是否已经更新，不能只看本地 `_site`。

### 5. 构建验证

本项目本地默认系统 Ruby 可能是 2.6，不能直接用系统 Ruby 判断构建失败。优先使用 Homebrew Ruby：

```bash
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec jekyll build
```

如果缺依赖，先执行：

```bash
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle install
```

不要尝试给系统 Ruby 2.6 安装 Bundler 4.x；Bundler 4.x 需要 Ruby >= 3.2。

### 6. 验证生成产物

构建后必须检查：

- `_site/index.html` 是否包含新增分类和链接。
- `_site/index.html` 是否包含 `.side-sections`。
- `_site/assets/css/style.css` 是否包含 `.home-outline { display: grid; ... }`。
- LeetCode 和 面试指南是否在生成 HTML 中存在。

### 7. GitHub Pages 线上验证

如果用户关心部署效果，必须额外检查线上页面和线上 CSS：

- `https://mykason.github.io/backend-interview/`
- `https://mykason.github.io/backend-interview/assets/css/style.css`

确认：

- 线上 HTML 包含 LeetCode。
- 线上 HTML 包含 面试指南。
- 线上 HTML 包含 `.side-sections`。
- 线上 CSS 包含 `.home-outline` 的 grid 样式。

如果 GitHub raw `main` 分支已有新内容，但线上页面没有，优先判断为 GitHub Pages 没有部署最新构建结果。

### 8. GitHub Pages 部署注意事项

本项目应使用 GitHub Actions 构建部署 Pages，避免 GitHub Pages 默认构建环境或缓存导致线上页面停留在旧版本。

确认存在：

```text
.github/workflows/pages.yml
```

工作流需要执行：

```bash
bundle exec jekyll build
```

并部署 `./_site`。

如果线上仍旧不更新，提醒用户检查 GitHub 仓库：

```text
Settings -> Pages -> Source -> GitHub Actions
```

### 9. 特别强调：今天修复过的问题

后续执行本 Skill 时必须特别避免以下问题：

1. **只改 `_site` 不改源文件**
   - `_site` 是构建产物，源头应优先改 `index.md`、`README.md`、`assets/css/style.scss`。
   - 只改 `_site` 会在下次 build 后丢失。

2. **本地正常不代表线上正常**
   - 本地 `127.0.0.1:4000/backend-interview/` 正常后，还要检查 GitHub Pages 线上 HTML 和 CSS。

3. **首页卡片必须使用 `.side-sections` 包裹右侧卡片**
   - LeetCode、Agent 开发、面试指南不能作为多个 direct children 散落在 `.home-outline` 下。

4. **GitHub Pages 旧页面问题要检查部署源**
   - 如果 raw main 有新内容但线上没有，通常是 Pages 构建/部署未更新，不是 HTML 写错。

5. **构建时使用 Homebrew Ruby**
   - 系统 Ruby 2.6 会因为 Bundler/Ruby 版本不兼容导致误判构建失败。

6. **README.md 和 index.md 要同步**
   - README 负责 Markdown 源文件目录。
   - index.md 负责 Pages 首页入口。
   - 新增知识内容时两者都要更新。

## 输出要求

完成后简短说明：

- 新增/更新了哪些 Markdown 内容。
- README.md 更新了哪些目录入口。
- index.md 更新了哪些首页卡片或链接。
- Jekyll build 是否通过。
- 如检查线上页面，说明线上是否已经包含 LeetCode、面试指南和最新 CSS。
