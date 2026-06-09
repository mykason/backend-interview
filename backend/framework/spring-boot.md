---
layout: page
title: "Spring Boot"
permalink: /backend/framework/spring-boot/
category: 后端知识
subcategory: 框架
---

## 概述

Spring Boot 简化了 Spring 应用的创建和配置，提供自动配置、内嵌服务器、起步依赖等特性，实现"约定优于配置"的开发体验。

## 核心特性

### 起步依赖（Starter）
- 预定义的依赖组合，简化 Maven/Gradle 配置
- 常用 Starter：

| Starter | 用途 |
|---------|------|
| spring-boot-starter-web | Web 开发（含内嵌 Tomcat） |
| spring-boot-starter-data-jpa | JPA 数据访问 |
| spring-boot-starter-data-redis | Redis |
| spring-boot-starter-security | 安全认证 |
| spring-boot-starter-actuator | 应用监控 |
| spring-boot-starter-test | 测试 |

### 自动配置
- 根据 classpath 中的类和已定义的 Bean 自动配置 Spring 应用
- 通过 `@Conditional` 系列注解实现条件装配
- 可通过 `@SpringBootApplication(exclude = {...})` 排除特定自动配置

### 内嵌服务器
- 默认 Tomcat，可切换为 Jetty、Undertow
- 无需部署 WAR 包，直接 `java -jar` 运行

## 配置管理

### application.yml / application.properties
```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: secret
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### Profile 多环境
```yaml
# application-dev.yml
spring:
  profiles: dev
server:
  port: 8080

---
# application-prod.yml
spring:
  profiles: prod
server:
  port: 80
```

激活方式：`--spring.profiles.active=dev`

### 自定义配置属性
```java
@ConfigurationProperties(prefix = "app")
@Component
public class AppConfig {
    private String name;
    private int maxSize;
    // getters & setters
}
```

## 数据访问

### Spring Data JPA
```java
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.status = :status")
    List<User> findByStatus(@Param("status") int status);
}
```

### MyBatis 集成
```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
</dependency>
```

### 多数据源
- 使用 `@Primary` 标注默认数据源
- 通过 `@Configuration` + `@MapperScan` 配置不同数据源的 SqlSessionFactory

## RESTful API 开发

### Controller
```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public List<User> list() { ... }

    @GetMapping("/{id}")
    public User get(@PathVariable Long id) { ... }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public User create(@RequestBody @Valid UserDTO dto) { ... }

    @PutMapping("/{id}")
    public User update(@PathVariable Long id, @RequestBody UserDTO dto) { ... }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) { ... }
}
```

### 全局异常处理
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Map<String, Object> handleException(Exception e) {
        return Map.of("code", 500, "message", e.getMessage());
    }
}
```

## 应用监控（Actuator）

### 常用端点
| 端点 | 说明 |
|------|------|
| /actuator/health | 健康检查 |
| /actuator/info | 应用信息 |
| /actuator/metrics | 指标数据 |
| /actuator/env | 环境变量 |
| /actuator/beans | 所有 Bean |

### 自定义 Health Indicator
```java
@Component
public class CustomHealthIndicator extends AbstractHealthIndicator {
    @Override
    protected void doHealthCheck(Health.Builder builder) {
        builder.up().withDetail("version", "1.0.0");
    }
}
```

## 打包与部署

### Maven 打包
```bash
mvn clean package -DskipTests
java -jar target/app.jar
```

### Docker 部署
```dockerfile
FROM eclipse-temurin:17-jre
COPY target/app.jar /app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## 常见面试题

### 1. Spring Boot 启动流程

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Spring Boot 启动流程本质是创建并刷新 Spring IOC 容器，同时完成环境准备、自动配置、Bean 初始化、内嵌 Web 服务启动和启动回调。 | Spring Boot 启动就是执行 `main` 方法，然后把 Spring 容器跑起来。 |
| 入口通常是 `SpringApplication.run()`，它会先创建 `SpringApplication` 实例，推断应用类型，加载初始化器和监听器。 | 好像会先 new 一个 `SpringApplication`，里面做一些初始化。 |
| 执行 `run()` 时会准备 `Environment`，加载命令行参数、系统环境变量、配置文件等配置源。 | 会读取 `application.yml`、环境变量这些配置。 |
| 根据应用类型创建 `ApplicationContext`，例如 Servlet Web 应用通常创建 `ServletWebServerApplicationContext`。 | 如果是 Web 项目，会创建一个 Web 相关的容器。 |
| 刷新容器是核心步骤，会扫描组件、加载自动配置、注册 BeanDefinition、实例化单例 Bean、完成依赖注入、执行 BeanPostProcessor，并在需要时创建 AOP 代理。 | 最重要的是刷新容器，扫描 Bean，然后把 Bean 创建出来，可能还会处理 AOP。 |
| Web 应用会在容器刷新过程中创建并启动内嵌服务器，例如 Tomcat、Jetty 或 Undertow。 | Web 项目最后会把 Tomcat 启起来。 |
| 启动完成后发布事件，执行 `CommandLineRunner`、`ApplicationRunner` 等回调，应用正式对外提供服务。 | 最后执行一些 Runner，项目就启动好了。 |

### 2. Spring Boot Starter 的工作流程

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Starter 的工作流程从引入依赖开始，使用方在 Maven 或 Gradle 中添加某个 `spring-boot-starter-*` 依赖。 | Starter 就是先在 `pom.xml` 里引一个依赖。 |
| Starter 会把该功能需要的依赖统一带入项目，例如 `spring-boot-starter-web` 会引入 Spring MVC、JSON、校验、内嵌 Tomcat 等相关依赖。 | 比如 web starter 会把 web、Tomcat 这些包带进来。 |
| 项目启动时，Spring Boot 自动配置机制会加载对应的自动配置类。 | 项目启动后，Spring Boot 会自动找相关配置类。 |
| 自动配置类通过 `@ConditionalOnClass`、`@ConditionalOnMissingBean`、`@ConditionalOnProperty` 等条件判断当前环境是否满足装配条件。 | 它会判断有没有某个类、有没有自己写过 Bean。 |
| 条件满足时，自动配置类向 IOC 容器注册默认 Bean；如果用户自定义了 Bean，通常用户配置优先。 | 满足条件就创建默认 Bean；自己配了的话一般用自己的。 |
| 最终效果是使用方只需要引入 Starter 和少量配置，就能获得一整套可用功能。 | 所以引入 starter 后，基本少写很多配置就能用。 |

### 3. Spring Boot 与 Spring Boot Starter 的区别

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Spring Boot 是一个应用开发框架，用于简化 Spring 应用创建、配置、运行和部署。 | Spring Boot 是一个框架，用来快速开发 Spring 项目。 |
| Spring Boot 提供自动配置、起步依赖、内嵌服务器、Actuator、外部化配置等能力。 | 它有自动配置、内嵌 Tomcat、配置文件这些东西。 |
| Spring Boot Starter 是 Spring Boot 生态中的依赖聚合包，用于简化某类功能的依赖引入。 | Starter 是依赖包的集合。 |
| Starter 本身通常不代表完整框架能力，而是把相关依赖和自动配置模块组织起来。 | Starter 不是框架本身，主要帮忙把需要的包引进来。 |
| 举例来说，Spring Boot 是整体机制，`spring-boot-starter-web` 是 Web 场景下的一组依赖入口。 | Spring Boot 是整体，web starter 是其中一个 web 依赖入口。 |
| 面试中可以总结为：Spring Boot 解决“怎么快速开发和运行应用”，Starter 解决“怎么快速引入某类功能依赖”。 | 简单说，Boot 管启动和自动配置，Starter 管依赖引入。 |

### 4. Sentinel 是如何实现限流的

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Sentinel 限流的核心是把接口、方法或服务调用抽象成资源，然后围绕资源统计实时访问指标并执行规则判断。 | Sentinel 限流就是先把接口当成一个资源。 |
| 请求进入资源时会经过一条 Slot Chain，例如统计、规则校验、熔断降级等处理节点。 | 请求进来会经过一串 Slot，好像里面有统计和规则判断。 |
| 限流判断主要依赖实时统计数据，例如 QPS、线程数、响应时间等。 | 它会统计 QPS、线程数这些指标。 |
| 常见流控模式包括直接限流、关联限流、链路限流；常见流控效果包括快速失败、Warm Up、排队等待。 | 规则里有直接、关联、链路，还有快速失败、预热、排队。 |
| 当请求超过规则阈值时，Sentinel 会抛出 `BlockException` 或执行降级处理，业务可通过 fallback 或 blockHandler 返回兜底结果。 | 超过阈值就会被拦住，走 blockHandler 或 fallback。 |
| Sentinel 还支持集群限流，把流量统计和令牌分配集中到 Token Server，避免单机限流不均。 | 它也能做集群限流，但细节有点记不清。 |

### 5. Nacos 配置中心的配置是如何写入 client 的，按照配置是否存在分开解释

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Nacos Client 启动时会根据 `serverAddr`、`namespace`、`group`、`dataId` 等信息向 Nacos Server 拉取配置。 | 客户端启动时会拿 dataId、group 去 Nacos 服务端拉配置。 |
| 如果服务端存在配置，Client 会拉取配置内容，写入本地缓存，并发布到 Spring Environment 中，应用通过 `@Value`、`@ConfigurationProperties` 等方式读取。 | 如果配置存在，就把配置拉下来，放到本地和 Spring 环境里。 |
| 在 Spring Cloud Alibaba 场景下，Nacos 配置通常作为较高优先级的 PropertySource 加入 Environment，因此能覆盖本地配置中相同 key。 | Nacos 配置优先级一般比较高，会覆盖本地同名配置。 |
| Client 还会通过长轮询监听配置变化，服务端配置变更后，Client 拉取新内容、更新本地缓存，并触发刷新事件。 | 后面配置改了，客户端会长轮询感知，然后刷新配置。 |
| 如果服务端不存在该配置，Client 通常不会写入远端配置内容，只会保留本地已有配置或默认值，启动是否失败取决于具体配置和是否强依赖该配置。 | 如果 Nacos 上没有配置，一般就用本地配置或者默认值。 |
| 对于不存在的配置，Client 仍可能建立监听；后续服务端新增该配置后，Client 能监听到变更并拉取写入本地缓存和 Environment。 | 但它可能还会监听，之后 Nacos 新增配置时再拉下来。 |

### 6. Spring Boot 自动配置原理？

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| 自动配置的核心是根据 classpath、已有 Bean、配置属性等条件，自动向容器注册合适的 Bean。 | 自动配置就是 Spring Boot 帮我们自动配 Bean。 |
| `@SpringBootApplication` 包含 `@EnableAutoConfiguration`，它会导入自动配置相关选择器。 | 启动类上的 `@SpringBootApplication` 里面包含自动配置。 |
| Spring Boot 2.x 主要通过 `spring.factories` 加载自动配置类，Spring Boot 3.x 主要通过 `AutoConfiguration.imports` 加载自动配置类。 | 它会从某个配置文件里读出一批自动配置类。 |
| 自动配置类内部大量使用 `@ConditionalOnClass`、`@ConditionalOnMissingBean`、`@ConditionalOnProperty` 等条件注解控制是否生效。 | 自动配置会判断有没有某个类、有没有某个 Bean、配置开没开。 |
| 如果用户已经自定义同类型 Bean，很多默认配置会因为 `@ConditionalOnMissingBean` 不再生效，从而让用户配置优先。 | 自己写了 Bean，一般就不会再用默认的。 |
| 可以通过 `exclude`、配置属性或自定义 Bean 来关闭、调整或覆盖默认自动配置。 | 不想用某个自动配置，可以 exclude 或自己写配置。 |

### 7. Spring Boot Starter 的原理？如何自定义 Starter？

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Starter 本质是依赖聚合包，用来把某类功能需要的依赖一次性引入，减少手工维护依赖的成本。 | Starter 就是一组依赖的集合。 |
| Starter 通常只负责依赖管理，真正的自动装配逻辑一般放在对应的 autoconfigure 模块中。 | Starter 里面不一定写很多代码，自动配置通常在另一个包里。 |
| 自定义 Starter 常见结构包括 `xxx-spring-boot-starter` 和 `xxx-spring-boot-autoconfigure` 两个模块。 | 自定义 starter 一般会分 starter 和 autoconfigure 两块。 |
| 在 autoconfigure 模块中定义配置属性类、自动配置类，并使用条件注解决定 Bean 是否注册。 | 要写配置类，创建 Bean，再加条件注解。 |
| Spring Boot 2.x 在 `META-INF/spring.factories` 声明自动配置类；Spring Boot 3.x 在 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 声明。 | 还要在 `META-INF` 下面的文件里声明自动配置类。 |
| 使用方引入 Starter 后，自动配置类被加载，相关 Bean 按条件注册到 IOC 容器中。 | 其他项目引入 starter 后，就能自动把功能配好。 |

### 8. Spring Boot 配置加载顺序？

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Spring Boot 配置来源很多，优先级越高的配置会覆盖优先级低的配置。 | Spring Boot 配置有优先级，高优先级覆盖低优先级。 |
| 常见高优先级来源包括命令行参数、Java 系统属性、操作系统环境变量、外部配置文件、classpath 内配置文件等。 | 命令行、环境变量、配置文件都会加载。 |
| 命令行参数优先级通常很高，例如 `--server.port=9090` 可以覆盖配置文件中的端口。 | 命令行传的 `server.port` 一般会覆盖 yml。 |
| 配置文件位置上，外部 `config/` 目录通常优先于外部当前目录，外部配置通常优先于 classpath 内部配置。 | jar 包外面的配置一般比 jar 包里面优先级高。 |
| Profile 配置会叠加在默认配置之上，例如 `application-prod.yml` 会覆盖 `application.yml` 中相同属性。 | 开了 prod 后，`application-prod.yml` 会覆盖默认配置。 |
| 排查最终生效配置时，可结合启动日志、`/actuator/env` 或配置绑定结果确认。 | 看不清哪个生效，可以看日志或 Actuator。 |

### 9. Spring Boot Actuator 的作用？

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| Actuator 用于提供生产级应用监控和管理能力，帮助查看应用健康、指标、配置、Bean、线程等运行状态。 | Actuator 是用来监控 Spring Boot 应用的。 |
| 常用端点包括 `/actuator/health`、`/actuator/info`、`/actuator/metrics`、`/actuator/env`、`/actuator/beans`。 | 常见接口有 health、info、metrics、env。 |
| `/health` 可用于健康检查，常被负载均衡、Kubernetes 探针或监控系统调用。 | health 用来看服务是不是健康。 |
| `/metrics` 可以暴露 JVM、HTTP 请求、线程、内存、GC 等指标，并可结合 Micrometer 对接 Prometheus 等系统。 | metrics 能看 JVM、接口、内存这些指标。 |
| 生产环境应谨慎暴露端点，通常只开放必要端点，并配合 Spring Security 做访问控制。 | 生产环境不要把所有端点都放开，env 这些比较敏感。 |
| 可以自定义 `HealthIndicator` 或指标，扩展业务健康检查和监控数据。 | 也可以自己写健康检查，比如检查 Redis。 |

### 10. Spring Boot 如何实现统一异常处理？

| 标准答案 | 靠记忆记忆不全的答案 |
|---|---|
| 通常使用 `@RestControllerAdvice` 或 `@ControllerAdvice` 配合 `@ExceptionHandler` 实现全局异常处理。 | 一般用 `@ControllerAdvice` 加 `@ExceptionHandler`。 |
| `@RestControllerAdvice` 等价于 `@ControllerAdvice` + `@ResponseBody`，适合 REST API 返回 JSON。 | 接口项目一般用 `@RestControllerAdvice`，会返回 JSON。 |
| 可以为业务异常、参数校验异常、系统异常分别定义处理方法，返回统一响应结构和合适的 HTTP 状态码。 | 可以分别处理业务异常、参数异常、未知异常。 |
| 对参数校验异常，如 `MethodArgumentNotValidException`，可以提取字段错误信息返回给前端。 | 参数校验失败时，把字段错误组装一下返回。 |
| 不建议直接把底层异常堆栈或敏感信息返回给客户端，日志中记录详细异常，响应中返回可理解的错误信息。 | 不要把异常堆栈直接返回前端，日志里记详细点。 |
| 统一异常处理能减少 Controller 中重复的 `try-catch`，让接口错误格式更稳定。 | 这样 Controller 里不用到处写 `try-catch`。 |
