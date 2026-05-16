---
layout: page
title: "TiDB"
permalink: /backend/database/tidb/
category: 后端知识
subcategory: 数据库
---

## 概述

TiDB 是 PingCAP 开源的分布式 NewSQL 数据库，兼容 MySQL 协议，支持水平扩展、强一致性事务、HTAP（混合事务/分析处理）。

## 核心架构

### 三大组件

```
Client
  ↓
TiDB (SQL 层)  →  PD (调度层)
  ↓               ↑
TiKV (存储层) ←───┘
```

| 组件 | 职责 | 特点 |
|------|------|------|
| **TiDB Server** | SQL 解析、优化、执行 | 无状态，可水平扩展 |
| **TiKV** | 数据存储（Key-Value） | 基于 Raft 的分布式 KV，事务支持 |
| **PD (Placement Driver)** | 元数据管理、调度、时间戳分配 | 集群大脑 |

### TiFlash（HTAP 扩展）
- 列式存储引擎，异步复制 TiKV 数据
- 用于实时分析查询，不影响 OLTP 性能

## 存储模型

### Key-Value 映射
- 每张表有主键或隐式 `_tidb_rowid`
- Key = `TableID_Prefix + RowID`
- Value = 编码后的行数据

### Region
- TiKV 中的数据按 Key 范围划分为 Region
- 默认 96MB 一个 Region
- PD 负责 Region 的分裂、合并、迁移（负载均衡）

## 事务模型

### MVCC + 乐观/悲观事务
- 基于 Percolator 模型
- 支持 **乐观事务** 和 **悲观事务**（默认悲观）
- 通过 PD 分配全局唯一递增时间戳实现 SI（Snapshot Isolation）

### 事务流程
1. 从 PD 获取 start_ts
2. 读取数据（MVCC 快照）
3. 写入本地缓存
4. 两阶段提交（2PC）：
   - Prewrite：锁住涉及 Key
   - Commit：获取 commit_ts，提交

## 与 MySQL 兼容性

### 兼容
- SQL 语法（SELECT、INSERT、UPDATE、DELETE、DDL）
- 事务（BEGIN、COMMIT、ROLLBACK）
- 预处理语句、JSON 类型
- 大部分 MySQL 内置函数

### 不兼容
- 存储过程、触发器、视图（部分支持）
- 外键约束（4.0+ 有限支持）
- 部分字符集和排序规则
- 自增 ID 不保证连续（全局唯一但可能跳号）

## 水平扩展

### 扩展存储
- 增加 TiKV 节点 → PD 自动调度 Region 到新节点
- 线性扩展存储容量

### 扩展计算
- 增加 TiDB Server 节点 → 无状态，直接增加并发能力
- 增加 TiFlash 节点 → 提升分析查询能力

## 数据迁移

### DM（Data Migration）
- 从 MySQL/MariaDB 全量 + 增量迁移到 TiDB
- 支持分表合并

### TiDB Lightning
- 快速全量导入（适用于大数据量初始化）
- 支持本地文件或 SQL dump

### TiCDC
- TiDB 增量数据变更捕获
- 同步到 Kafka、MySQL、其他 TiDB 集群

## HTAP 场景

### TiFlash 实时分析
```sql
-- 强制使用 TiFlash（列存）执行
SELECT /*+ read_from_storage(tiflash[table_name]) */
    date(created_at), COUNT(*), SUM(amount)
FROM orders
GROUP BY date(created_at);
```

### MPP 模式（5.0+）
- TiFlash 节点之间并行计算
- 大幅提升分析查询性能

## 运维监控

### TiUP
- 官方部署管理工具
- 一键部署、扩容、缩容、升级

```bash
tiup cluster deploy my-cluster v7.0.0 topology.yaml
tiup cluster start my-cluster
tiup cluster scale-out my-cluster scale.yaml
```

### Grafana 监控
- 内置 Dashboard 监控各组件指标
- 慢查询日志：`ADMIN SHOW SLOW`

## 常见面试题

1. TiDB 的整体架构？
2. TiDB 和 MySQL 的区别？
3. TiDB 如何实现分布式事务？
4. Region 是什么？PD 如何调度？
5. 什么是 HTAP？TiFlash 的作用？

## 参考资料

- [TiDB 官方文档](https://docs.pingcap.com/zh/tidb/stable)
- [TiDB 源码阅读](https://pingcap.com/zh/tidb-source-code-reading/)
