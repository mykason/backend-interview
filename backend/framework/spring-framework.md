---
layout: page
title: "Spring Framework"
permalink: /backend/framework/spring-framework/
category: 后端知识
subcategory: 框架
---

## 概述

Spring Framework 是 Java 企业级应用开发的基础框架，提供 IoC 容器、AOP、数据访问、Web MVC 等全面的基础设施支持。

## IoC（控制反转）

### 核心概念
- **IoC 容器**：负责对象的创建、装配和生命周期管理
- **Bean**：由 Spring 容器管理的对象
- **依赖注入（DI）**：容器自动注入对象所需的依赖

### 注入方式
- 构造器注入（推荐）
- Setter 注入
- 字段注入（@Autowired，不推荐）

### Bean 作用域
| 作用域 | 说明 |
|--------|------|
| singleton | 默认，容器中只有一个实例 |
| prototype | 每次获取创建新实例 |
| request | Web 环境，每个 HTTP 请求一个 |
| session | Web 环境，每个 Session 一个 |

### Bean 生命周期
1. 实例化（Instantiation）
2. 属性赋值（Populate properties）
3. BeanNameAware / BeanFactoryAware
4. BeanPostProcessor.postProcessBeforeInitialization
5. InitializingBean.afterPropertiesSet / @PostConstruct
6. init-method
7. BeanPostProcessor.postProcessAfterInitialization
8. 使用
9. DisposableBean.destroy / @PreDestroy
10. destroy-method

## AOP（面向切面编程）

### 核心术语
- **切面（Aspect）**：横切关注点的模块化
- **连接点（JoinPoint）**：程序执行的某个点（方法调用）
- **切入点（Pointcut）**：匹配连接点的表达式
- **通知（Advice）**：在切入点执行的动作
  - @Before、@After、@AfterReturning、@AfterThrowing、@Around

### 实现原理
- **JDK 动态代理**：基于接口，目标类必须实现接口
- **CGLIB 代理**：基于继承，生成目标类的子类

### 切入点表达式
```java
@Pointcut("execution(* com.example.service.*.*(..))")
```

## 事务管理

### 声明式事务（@Transactional）
```java
@Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_COMMITTED)
public void transfer(Account from, Account to, BigDecimal amount) {
    // ...
}
```

### 事务传播行为
| 传播行为 | 说明 |
|----------|------|
| REQUIRED | 默认，有事务加入，无事务新建 |
| REQUIRES_NEW | 始终新建事务，挂起当前事务 |
| NESTED | 嵌套事务（保存点） |
| SUPPORTS | 有事务加入，无事务非事务执行 |
| NOT_SUPPORTED | 非事务执行，挂起当前事务 |
| MANDATORY | 必须在事务中，否则抛异常 |
| NEVER | 非事务执行，存在事务则抛异常 |

### 事务失效场景
1. 方法非 public
2. 自调用（同类中方法 A 调方法 B，B 的事务不生效）
3. 异常被 catch 未抛出
4. 默认只对 RuntimeException 回滚

## 自动配置原理

### @SpringBootApplication 组合注解
- `@SpringBootConfiguration`：标识配置类
- `@EnableAutoConfiguration`：启用自动配置
- `@ComponentScan`：组件扫描

### 自动配置流程
1. `@EnableAutoConfiguration` 通过 `@Import(AutoConfigurationImportSelector.class)` 导入
2. 读取 `META-INF/spring.factories`（Spring Boot 2.x）或 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`（Spring Boot 3.x）
3. 根据 @Conditional 系列注解条件过滤

## 循环依赖

### 三级缓存
1. **singletonObjects**：完整 Bean
2. **earlySingletonObjects**：早期引用（未完成初始化）
3. **singletonFactories**：Bean 工厂

### 解决流程（A → B → A）
1. A 实例化后，将 A 的工厂放入三级缓存
2. A 注入 B，触发 B 的创建
3. B 注入 A，从三级缓存获取 A 的早期引用
4. B 创建完成，A 完成注入

> 构造器注入的循环依赖无法解决，需用 @Lazy。

## 常见面试题

1. Spring IoC 的理解？Bean 的生命周期？
2. Spring AOP 的实现原理？
3. @Transactional 事务失效的场景？
4. Spring 如何解决循环依赖？
5. Spring Boot 自动配置原理？

## 参考资料

- [Spring 官方文档](https://docs.spring.io/spring-framework/reference/)
