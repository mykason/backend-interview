# Kafka 如何保证高吞吐的？
- 磁盘顺序读写
-- Kafka 将消息追加（Append）到日志文件的末尾，避免了磁盘磁头的频繁寻道时间（Seek Time），极大地提升了写入速度
- 零拷贝技术 (Zero-Copy)
-- 传统的网络数据发送需要经历：磁盘 -> 内核层(Read Buffer) -> 用户层(Application Buffer) -> 内核层(Socket Buffer) -> 网卡，这中间涉及多次 CPU 上下文切换和数据拷贝
-- Kafka 在消费者拉取数据时，利用了 Linux 的 sendfile 系统调用。数据直接从操作系统的页缓存（Page Cache）拷贝到网卡，完全绕过了用户态进程（JVM）
-- 大大减少了 CPU 上下文切换的开销和内存拷贝次数，极大地提高了网络数据传输效率。
- 充分利用操作系统的页缓存 (Page Cache)
-- Kafka 并没有在 JVM 内存中维护大量的缓存结构，而是将数据交给了操作系统的 Page Cache 来管理
-- 生产者写入数据时，其实是写到了 Page Cache 中就直接返回，由操作系统异步刷盘；消费者读取数据时，如果数据刚刚写入，通常可以直接从 Page Cache 中命中，相当于完全在内存中进行交互
- 批处理与压缩 (Batching & Compression)
-- Kafka 的 Producer 并不是来一条消息就发一条，而是将消息放进内存池（RecordAccumulator）中。通过配置 batch.size（批次大小）和 linger.ms（等待时间），将多条消息打包成一个批次一次性发送。这极大地减少了网络 IO 次数
-- 配合批处理，Kafka 支持在 Producer 端对整个批次的数据进行压缩（如 Snappy, LZ4, Zstd）
- 分区架构与并发 (Partitioning)
-- Kafka 的 Topic 被划分为多个 Partition（分区），这些 Partition 可以分布在集群中的不同 Broker（服务器）上。
-- 这是一种完美的水平扩展设计。无论是 Producer 写入还是 Consumer 读取，都可以针对不同的 Partition 并发进行。只要增加 Partition 的数量和相应的机器，就能线性地提升整体集群的吞吐量

# Kafka 如何保证消息不丢失？
- 首先在生产端，我会把 acks 设为 all，开启重试机制，并使用带有 Callback 的发送 API 来确保消息确实到达了集群。
其次在Broker端，我会保证 Topic 至少有 3 个副本，并且把 min.insync.replicas 设置为 2 以上，同时关闭不干净的 Leader 选举，防止脑裂和数据截断。
最后在消费端，我会关闭自动提交，改成在业务逻辑完全处理成功后，再手动提交 Offset，实现‘At-Least-Once’（至少一次）的语义。如果有重复消费的风险，我会在下游业务侧做幂等性处理。这套组合拳下来，基本就能确保数据万无一失了。
