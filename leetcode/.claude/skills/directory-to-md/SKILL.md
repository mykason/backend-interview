---
name: directory-to-md
description: 将指定目录下的文件整理/转换为 Markdown 页面，并更新 backend-interview 的 index.md。适用于用户要求把某个目录内容发布成可读 md 文档或同步到知识大纲时。
argument-hint: "<目录> [标题] [index分类]"
arguments:
  - directory
  - title
  - index_category
---

# Directory to Markdown

把用户指定的 `$directory` 中的文件转换为可读的 Markdown，并同步更新 `~/Mywork/github/backend-interview/index.md`。

## 输入

- 必填：目录路径，可以是相对当前工作目录的路径，也可以是绝对路径。
- 可选：页面标题；未提供时根据目录名生成。
- 可选：`index.md` 中要挂载的分类/小节；未提供时先根据目录位置和现有结构判断，不确定则询问用户。

## 执行步骤

1. 确认目录存在且是目录。
   - 如果路径不存在，停止并告诉用户。
   - 如果目录下没有可转换文件，停止并告诉用户。

2. 读取目录内容。
   - 优先处理文本文件、源码文件、配置文件、Markdown 文件。
   - 跳过二进制文件、压缩包、图片、构建产物、依赖目录（如 `node_modules`、`target`、`dist`、`.git`）。
   - 文件较多时，先列出将要转换的文件，让用户确认范围。

3. 生成 Markdown 页面。
   - 输出位置优先放在 `~/Mywork/github/backend-interview/` 下与主题匹配的目录中。
   - 如果源文件已经是 Markdown，可以保留原有结构，只做必要整理。
   - 如果源文件是代码或配置，必须用 fenced code block 包裹，并标注语言，例如：

     ```java
     // code
     ```

   - 每个文件内容建议使用以下结构，保证代码可读性：

     ````markdown
     ---
     layout: default
     title: "页面标题"
     ---

     # 页面标题

     ## 文件：relative/path/File.java

     ```java
     原始代码内容
     ```
     ````

   - 保留原始缩进、空行和注释，不要压缩代码。
   - 对很长的文件，按文件拆分成多个小节；不要把代码改写成伪代码。
   - Markdown 中嵌套代码块时，外层 fence 使用比内层更长的反引号，避免破坏格式。

4. 更新 `~/Mywork/github/backend-interview/index.md`。
   - 先读取当前 `index.md`，保持现有 Jekyll/Liquid 链接风格：

     ```html
     <li><a href="{{ '/path/to/page' | relative_url }}">标题</a></li>
     ```

   - 将新页面链接插入到最匹配的小节中。
   - 如果没有合适小节，先询问用户是否新增小节；不要随意重构整个首页。
   - 避免重复添加同一个链接。

5. 完成后检查。
   - 报告新增/更新的 Markdown 文件路径。
   - 报告 `index.md` 中新增的链接位置。
   - 如果无法确定分类、标题或输出位置，向用户提问后再修改。

## 建议

- 转换大目录时，优先按主题拆成多个 Markdown 文件，而不是生成一个超长页面。
- 如果目录里既有题解/说明又有源码，说明文字放前面，源码放后面。
- 如果需要频繁执行，可以增加一个脚本放在本 skill 的 `scripts/` 目录中，用于自动识别语言并生成 Markdown；在未确认需求前不要创建脚本。
