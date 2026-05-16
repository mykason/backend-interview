---
layout: page
title: "MySQL"
permalink: /backend/database/mysql/
category: 后端知识
subcategory: 数据库
---

## 概述

MySQL 是最流行的开源关系型数据库，广泛用于 Web 应用、OLTP 场景。InnoDB 存储引擎提供了事务、行级锁、MVCC 等高级特性。

## 存储引擎

| 特性 | InnoDB | MyISAM |
|------|--------|--------|
| 事务 | 支持 | 不支持 |
| 锁粒度 | 行级锁 | 表级锁 |
| 外键 | 支持 | 不支持 |
| MVCC | 支持 | 不支持 |
| 崩溃恢复 | 支持（redo log） | 不支持 |
| 全文索引 | 支持（5.6+） | 支持 |

## 索引

### 索引类型
- **主键索引（聚簇索引）**：叶子节点存储完整行数据
- **二级索引（非聚簇索引）**：叶子节点存储主键值
- **联合索引**：多个列组合索引，遵循最左前缀原则
- **覆盖索引**：查询字段全部在索引中，无需回表

### B+ Tree 索引结构
- 非叶子节点只存 key，叶子节点存数据并形成链表
- 范围查询高效

### 索引优化原则
1. 选择高选择性列（区分度高）
2. 联合索引遵循最左前缀
3. 避免在索引列上使用函数
4. 避免 SELECT *，尽量使用覆盖索引
5. 注意索引列的顺序

## 事务

### ACID 特性
- **原子性（Atomicity）**：undo log 保证
- **一致性（Consistency）**：其他三个特性共同保证
- **隔离性（Isolation）**：MVCC + 锁保证
- **持久性（Durability）**：redo log 保证

### 隔离级别
| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|----------|------|-----------|------|
| READ UNCOMMITTED | 有 | 有 | 有 |
| READ COMMITTED | 无 | 有 | 有 |
| REPEATABLE READ（默认） | 无 | 无 | 部分防止 |
| SERIALIZABLE | 无 | 无 | 无 |

## MVCC（多版本并发控制）

### 核心组件
- **隐藏列**：DB_TRX_ID（事务ID）、DB_ROLL_PTR（回滚指针）
- **undo log 版本链**：通过回滚指针串联历史版本
- **ReadView**：决定当前事务能看到哪个版本

### ReadView 规则
- RC 级别：每次 SELECT 生成新 ReadView
- RR 级别：只在第一次 SELECT 生成 ReadView

## 锁机制

### 锁类型
- **共享锁（S）**：读锁，多个事务可同时持有
- **排他锁（X）**：写锁，独占
- **意向锁**：表级锁，快速判断表中是否有行锁
- **Gap Lock**：间隙锁，防止幻读
- **Next-Key Lock**：行锁 + Gap Lock（左开右闭）

### 锁等待问题排查
```sql
-- 查看锁等待
SELECT * FROM information_schema.INNODB_LOCK_WAITS;
-- 查看当前锁
SELECT * FROM performance_schema.data_locks;
-- 杀死阻塞线程
KILL <thread_id>;
```

## 日志系统

### redo log
- InnoDB 引擎日志，物理日志
- 保证持久性，crash-safe
- 环形写入，write pos 追 checkpoint

### undo log
- 逻辑日志，记录数据修改前的值
- 保证原子性（事务回滚）
- MVCC 版本链的基础

### binlog
- Server 层日志，逻辑日志
- 主从复制、数据恢复
- 三种格式：STATEMENT、ROW、MIXED

### 两阶段提交
```
redo log prepare → binlog 写入 → redo log commit
```
保证 redo log 和 binlog 的一致性。

## SQL 优化

### EXPLAIN 分析
```sql
EXPLAIN SELECT * FROM users WHERE age > 20;
```

关键字段：
- **type**：访问类型（system > const > eq_ref > ref > range > index > ALL）
- **key**：实际使用的索引
- **rows**：预估扫描行数
- **Extra**：额外信息（Using index = 覆盖索引）

### 慢查询优化
1. 开启慢查询日志
2. 用 EXPLAIN 分析执行计划
3. 优化索引
4. 避免 SELECT *
5. 分页优化（游标分页替代 OFFSET）

## 常见面试题

1. MySQL 为什么用 B+ 树而不是 B 树？
2. 聚簇索引和非聚簇索引的区别？
3. MVCC 原理？RC 和 RR 的区别？
4. redo log、undo log、binlog 的区别？
5. 如何优化慢查询？

## 参考资料

- 《高性能 MySQL》
- 《MySQL 技术内幕：InnoDB 存储引擎》
