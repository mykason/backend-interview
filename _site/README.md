# Backend Interview

> 后端开发、Agent 开发、面试准备与算法题知识库，基于 Jekyll 构建，部署于 GitHub Pages。

## 在线目录

首页入口：`index.md`

### 后端知识

#### JAVA 基础

- [Java 基础](backend/java-basic/base.md)
- [集合](backend/java-basic/collection.md)
- [JVM](backend/java-basic/jvm.md)
- [多线程](backend/thread/multithreading.md)
- [AOP](backend/java-basic/aop.md)

#### 框架

- [Spring Framework](backend/framework/spring-framework.md)
- [Spring Boot](backend/framework/spring-boot.md)
- [Spring Cloud](backend/framework/spring-cloud.md)

#### 数据库

- [MySQL](backend/database/mysql.md)
- [Redis](backend/database/redis.md)
- [Elasticsearch](backend/database/elasticsearch.md)
- [TiDB](backend/database/tidb.md)

### Agent 开发

- [LangChain](agent/langchain.md)
- [LangGraph](agent/langgraph.md)

### 面试指南

- [面试复习路径](guide/interview.md)

### LeetCode

- [Hot 100](leetcode/hot100.md)

### 职场成长

- [如何在绩效考核中脱颖而出](woker/aboutPerformance.md)

## 项目结构

```text
backend-interview/
├── _config.yml                  # Jekyll 站点配置
├── _layouts/                    # 页面布局模板
│   ├── default.html             # 默认布局
│   └── page.html                # 内容页布局
├── assets/css/                  # 样式文件
├── agent/                       # Agent 开发
│   ├── langchain.md
│   └── langgraph.md
├── backend/                     # 后端知识
│   ├── database/                # 数据库
│   │   ├── elasticsearch.md
│   │   ├── mysql.md
│   │   ├── redis.md
│   │   └── tidb.md
│   ├── framework/               # 框架
│   │   ├── spring-boot.md
│   │   ├── spring-cloud.md
│   │   └── spring-framework.md
│   ├── java-basic/              # Java 基础
│   │   ├── aop.md
│   │   ├── base.md
│   │   ├── collection.md
│   │   └── jvm.md
│   └── thread/
│       └── multithreading.md
├── guide/
│   └── interview.md             # 面试指南
├── leetcode/
│   └── hot100.md                # 算法题
├── woker/
│   └── aboutPerformance.md      # 职场成长
├── index.md                     # GitHub Pages 首页
└── README.md
```

## 本地预览

```bash
bundle install
bundle exec jekyll serve
```

访问 `http://127.0.0.1:4000/backend-interview/`。

## 作者

- **Kason**
- Email: mykason163@gmail.com
- GitHub: [https://github.com/mykason](https://github.com/mykason)

## 许可证

MIT License
