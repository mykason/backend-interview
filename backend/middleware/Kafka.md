---
layout: page
title: "Kafka"
permalink: /backend/middleware/Kafka/
category: 后端知识
subcategory: 中间件
---

# Kafka 如何保证高吞吐？

## 磁盘顺序读写

Kafka 将消息追加（Append）到日志文件末尾，避免磁盘磁头频繁寻道（Seek Time），极大提升写入速度。

## 零拷贝技术（Zero-Copy）

传统网络数据发送需要经历：

```text
磁盘 -> 内核层（Read Buffer）-> 用户层（Application Buffer）-> 内核层（Socket Buffer）-> 网卡
```

这个过程涉及多次 CPU 上下文切换和数据拷贝。

Kafka 在消费者拉取数据时，利用 Linux 的 `sendfile` 系统调用，数据可以直接从操作系统页缓存（Page Cache）拷贝到网卡，绕过用户态进程（JVM）。这样可以减少 CPU 上下文切换和内存拷贝次数，提升网络数据传输效率。

## 充分利用操作系统页缓存（Page Cache）

Kafka 并没有在 JVM 内存中维护大量缓存结构，而是将数据交给操作系统的 Page Cache 管理。

- 生产者写入数据时，通常写入 Page Cache 后就直接返回，由操作系统异步刷盘。
- 消费者读取数据时，如果数据刚刚写入，通常可以直接从 Page Cache 命中，相当于在内存中完成交互。

## 批处理与压缩（Batching & Compression）

Kafka Producer 并不是来一条消息就发送一条，而是将消息放入内存池（RecordAccumulator）中。

通过配置：

- `batch.size`：批次大小
- `linger.ms`：等待时间

可以将多条消息打包成一个批次一次性发送，从而减少网络 IO 次数。

配合批处理，Kafka 支持在 Producer 端对整个批次的数据进行压缩，例如 Snappy、LZ4、Zstd。

## 分区架构与并发（Partitioning）

Kafka 的 Topic 会被划分为多个 Partition，这些 Partition 可以分布在集群中的不同 Broker 上。

这种设计天然支持水平扩展：

- Producer 可以针对不同 Partition 并发写入。
- Consumer 可以针对不同 Partition 并发读取。
- 增加 Partition 数量和对应机器后，可以线性提升整体集群吞吐量。

# Kafka 如何保证消息不丢失？

## 生产端

- 将 `acks` 设置为 `all`。
- 开启重试机制。
- 使用带 Callback 的发送 API，确认消息确实到达 Kafka 集群。

## Broker 端

- Topic 至少设置 3 个副本。
- 将 `min.insync.replicas` 设置为 2 以上。
- 关闭不干净的 Leader 选举，防止脑裂和数据截断。

## 消费端

- 关闭自动提交。
- 在业务逻辑完全处理成功后，再手动提交 Offset。
- 实现 `At-Least-Once`（至少一次）语义。
- 如果存在重复消费风险，需要在下游业务侧做幂等处理。

这套组合可以最大限度降低消息丢失风险。
