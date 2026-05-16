---
layout: page
title: "Elasticsearch"
permalink: /backend/database/elasticsearch/
category: 后端知识
subcategory: 数据库
---

## 概述

Elasticsearch 是一个基于 Lucene 的分布式搜索和分析引擎，擅长全文检索、日志分析、实时数据分析等场景。

## 核心概念

| Elasticsearch | 关系型数据库 |
|---------------|-------------|
| Index | Database |
| Type（已废弃） | Table |
| Document | Row |
| Field | Column |
| Mapping | Schema |

### Document（文档）
- JSON 格式
- 每个 document 有唯一 `_id`
- 属于某个 Index

### Mapping（映射）
- 定义字段的类型和分析方式
- 动态映射（自动推断）和显式映射（手动定义）

```json
PUT /products
{
  "mappings": {
    "properties": {
      "name": { "type": "text", "analyzer": "ik_max_word" },
      "price": { "type": "double" },
      "tags": { "type": "keyword" },
      "created": { "type": "date" }
    }
  }
}
```

## 倒排索引

```
文档1: "Elasticsearch 是搜索引擎"
文档2: "搜索引擎用于全文检索"

Term         | Doc IDs
-------------|--------
elasticsearch| [1]
搜索引擎      | [1, 2]
全文检索      | [2]
```

- 正排索引：文档 → 词
- 倒排索引：词 → 文档（ES 的核心数据结构）

## 分词器（Analyzer）

### 组成
1. **Character Filters**：预处理（HTML 去除等）
2. **Tokenizer**：分词
3. **Token Filters**：词项过滤（小写、同义词等）

### 常用分词器
| 分词器 | 说明 |
|--------|------|
| standard | 默认，按单词边界分词 |
| simple | 按非字母分词，转小写 |
| whitespace | 按空格分词 |
| ik_max_word | IK 中文最细粒度分词 |
| ik_smart | IK 中文智能分词 |

## 核心查询 DSL

### 查询所有
```json
GET /products/_search
{
  "query": { "match_all": {} }
}
```

### 全文检索
```json
{
  "query": {
    "match": {
      "name": "搜索引擎"
    }
  }
}
```

### 精确匹配
```json
{
  "query": {
    "term": {
      "tags": "electronics"
    }
  }
}
```

### 复合查询（bool）
```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "手机" } }
      ],
      "filter": [
        { "range": { "price": { "gte": 1000, "lte": 5000 } } }
      ],
      "should": [
        { "term": { "brand": "apple" } }
      ],
      "must_not": [
        { "term": { "status": "discontinued" } }
      ]
    }
  }
}
```

### 聚合分析
```json
{
  "size": 0,
  "aggs": {
    "brand_stats": {
      "terms": { "field": "brand", "size": 10 }
    },
    "price_stats": {
      "stats": { "field": "price" }
    }
  }
}
```

## 分布式架构

### 分片（Shard）
- **主分片（Primary Shard）**：数据分片，创建后不可修改数量
- **副本分片（Replica Shard）**：主分片拷贝，提供高可用和读扩展

### 路由规则
```
shard = hash(routing) % number_of_primary_shards
```

### 写入流程
1. 客户端发送请求到协调节点
2. 路由到主分片所在节点
3. 主分片写入后同步到副本分片
4. 返回客户端

### 搜索流程（Query Then Fetch）
1. **Query 阶段**：协调节点将请求发给所有分片，各分片返回匹配文档 ID 和排序值
2. **Fetch 阶段**：协调节点根据排序值取 top N，从相关分片获取完整文档

## 与关系型数据库同步

### Canal + Kafka
1. Canal 监听 MySQL binlog
2. 发送到 Kafka
3. 消费 Kafka 写入 Elasticsearch

## 性能优化

1. 合理设置分片数（建议单个分片 10-50GB）
2. 使用 filter 替代 query（filter 可缓存）
3. 避免深度分页（使用 search_after）
4. 预索引字段优化 range 查询
5. 使用 bulk 批量操作

## 常见面试题

1. Elasticsearch 的倒排索引原理？
2. 写入和查询的流程？
3. 如何实现 MySQL 与 ES 的数据同步？
4. 如何优化 Elasticsearch 查询性能？
5. 分片和副本的作用？

## 参考资料

- [Elasticsearch 官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- 《Elasticsearch 权威指南》
