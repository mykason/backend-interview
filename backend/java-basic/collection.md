---
layout: page
title: "集合"
permalink: /backend/java-basic/collection/
category: 后端知识
subcategory: JAVA 基础
---

## 概述

Java 集合框架（Java Collections Framework）是 Java 中用于存储和操作一组对象的一套统一架构。

## 核心接口体系

- **Collection**：单列集合的根接口
- **Map**：双列（键值对）集合的根接口

## List

### ArrayList
- 底层基于动态数组实现
- 随机访问快（O(1)），插入/删除慢（O(n)）
- 默认初始容量 10，扩容为原来的 1.5 倍
- 非线程安全

### LinkedList
- 底层基于双向链表实现
- 插入/删除快（O(1)），随机访问慢（O(n)）
- 同时实现了 List 和 Deque 接口

### Vector
- 线程安全的动态数组（方法用 synchronized 修饰）
- 性能较差，一般使用 `Collections.synchronizedList()` 或 `CopyOnWriteArrayList` 替代

## Set

### HashSet
- 底层基于 HashMap 实现
- 无序，允许 null 元素
- 插入/查找/删除 O(1)

### LinkedHashSet
- 维护插入顺序的 HashSet

### TreeSet
- 基于 TreeMap（红黑树）实现
- 元素自然排序或自定义 Comparator 排序

## Map

### HashMap
- 底层：数组 + 链表 + 红黑树（JDK 8+）
- 默认容量 16，负载因子 0.75
- 链表长度 >= 8 且数组长度 >= 64 时转红黑树
- 非线程安全，允许 null key 和 null value

### ConcurrentHashMap
- 线程安全的 HashMap
- JDK 7：分段锁（Segment）
- JDK 8+：CAS + synchronized（锁粒度为桶节点）

### TreeMap
- 基于红黑树实现
- 按 key 自然排序或自定义排序

## Queue

### PriorityQueue
- 基于堆（数组）实现的优先队列
- 出队顺序按优先级（自然排序或 Comparator）

### ArrayDeque
- 基于循环数组实现的双端队列
- 可作为栈或队列使用，效率高于 LinkedList

## 常见面试题

1. HashMap 的扩容机制？
2. HashMap 和 Hashtable 的区别？
3. ConcurrentHashMap 如何保证线程安全？
4. ArrayList 的扩容机制？
5. Comparable 和 Comparator 的区别？

## 参考资料

- [Java 官方文档 - Collections Framework](https://docs.oracle.com/javase/8/docs/technotes/guides/collections/overview.html)
