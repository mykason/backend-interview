---
layout: page
title: "Spring Cloud"
permalink: /backend/framework/spring-cloud/
category: 后端知识
subcategory: 框架
---

## 概述

Spring Cloud 是基于 Spring Boot 的微服务框架，提供服务注册发现、配置管理、负载均衡、熔断器、网关等微服务基础设施。

## 核心组件

### 服务注册与发现

#### Nacos（推荐）
- 阿里开源，同时支持 AP/CP 模式
- 集服务注册、配置中心于一体
- 支持DNS和HTTP服务发现

```yaml
# application.yml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848
      config:
        server-addr: localhost:8848
        file-extension: yaml
```

#### Eureka（Netflix，已停更）
- AP 模式，保证可用性
- 自我保护机制：心跳失败比例过高时不再剔除服务

### 配置中心

#### Nacos Config
- 支持动态配置推送，实时生效
- 支持 YAML、Properties、JSON 等格式
- 按 Data ID + Group 管理配置

#### Spring Cloud Config
- 基于 Git 仓库的集中配置管理
- 支持配置加密/解密

### 负载均衡

#### Spring Cloud LoadBalancer（替代 Ribbon）
- 轮询（RoundRobin）
- 随机（Random）
- 自定义策略

```java
@Bean
@LoadBalanced
public RestTemplate restTemplate() {
    return new RestTemplate();
}
```

### 服务调用

#### OpenFeign
- 声明式 HTTP 客户端，结合负载均衡

```java
@FeignClient(name = "user-service")
public interface UserClient {
    @GetMapping("/api/users/{id}")
    User getUser(@PathVariable("id") Long id);
}
```

### 熔断与降级

#### Sentinel（推荐）
- 阿里开源，轻量级流量控制组件
- 支持流控、熔断、系统保护、热点限流
- 控制台实时监控

#### Resilience4j
- 轻量级、函数式
- 支持 Circuit Breaker、Rate Limiter、Retry、Bulkhead

### API 网关

#### Spring Cloud Gateway
- 基于 WebFlux（Netty），非阻塞
- 核心：Route + Predicate + Filter

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/users/**
          filters:
            - StripPrefix=0
            - name: CircuitBreaker
              args:
                name: userCircuitBreaker
```

### 分布式事务

#### Seata
- 支持 AT、TCC、Saga、XA 模式
- AT 模式最常用，对业务无侵入

## 微服务架构参考

```
Client → Gateway → [Service A, Service B, Service C]
                      ↓              ↓
                    Nacos (注册中心 & 配置中心)
                      ↓
                    Sentinel (熔断限流)
```

## 版本对应关系

| Spring Cloud | Spring Boot |
|--------------|-------------|
| 2023.0.x (Leyton) | 3.2.x |
| 2022.0.x (Kilburn) | 3.0.x |
| 2021.0.x (Jubilee) | 2.6.x - 3.0.x |

## 常见面试题

1. 微服务的优缺点？
2. Spring Cloud 各组件的作用？
3. 服务注册发现原理？
4. 熔断器的工作原理（三种状态）？
5. 分布式事务的解决方案？

## 参考资料

- [Spring Cloud 官方文档](https://spring.io/projects/spring-cloud)
- [Nacos 官方文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)
