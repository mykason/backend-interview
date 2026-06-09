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

| 标准答案 | 靠记忆又记忆不全的版本 |
|---|---|
| Spring Boot 启动流程本质是创建并刷新 Spring IOC 容器，同时完成环境准备、自动配置、Bean 初始化和 Web 服务启动。 | Spring Boot 启动大概就是先跑 `main` 方法，然后把 Spring 容器启动起来。 |
| 入口通常是 `SpringApplication.run()`。它会先创建 `SpringApplication` 对象，推断应用类型，加载初始化器和监听器。 | 好像会先创建一个 `SpringApplication`，里面会做一些初始化。 |
| 执行 `run()` 时，会准备 `Environment`，加载配置文件、命令行参数、系统环境变量等配置源。 | 会读 `application.yml` 或 `application.properties`，还有一些环境变量。 |
| 根据应用类型创建 `ApplicationContext`，例如 Servlet Web 应用通常创建 `ServletWebServerApplicationContext`。 | 如果是 Web 项目，会创建一个 Web 相关的容器。 |
| 刷新容器是核心步骤：扫描 Bean、加载自动配置、注册 BeanDefinition、实例化单例 Bean、处理依赖注入、BeanPostProcessor、AOP 代理等。 | 最重要的是刷新容器，会扫描 Bean，然后把 Bean 创建出来，可能还会处理 AOP。 |
| Web 应用会在容器刷新过程中创建并启动内嵌 Web 服务器，例如 Tomcat、Jetty 或 Undertow。 | Web 项目最后会把 Tomcat 启起来。 |
| 启动完成后发布事件，执行 `CommandLineRunner`、`ApplicationRunner` 等回调，应用正式对外提供服务。 | 最后会执行一些 Runner，然后项目就启动好了。 |

### 2. Spring Boot 自动配置原理？

| 标准答案 | 靠记忆又记忆不全的版本 |
|---|---|
| 自动配置的核心是根据 classpath、已有 Bean、配置属性等条件，自动向容器注册合适的 Bean。 | 自动配置就是 Spring Boot 帮我们自动配 Bean，不用自己写很多 XML。 |
| `@SpringBootApplication` 包含 `@EnableAutoConfiguration`，它会导入自动配置相关的选择器。 | 启动类上的 `@SpringBootApplication` 里面好像有自动配置功能。 |
| Spring Boot 2.x 主要通过 `spring.factories` 加载自动配置类，Spring Boot 3.x 主要通过 `AutoConfiguration.imports` 加载。 | 它会从某个配置文件里把自动配置类读出来。 |
| 自动配置类内部大量使用 `@ConditionalOnClass`、`@ConditionalOnMissingBean`、`@ConditionalOnProperty` 等条件注解。 | 自动配置不是无脑生效的，会判断有没有某个类、有没有某个 Bean。 |
| 如果用户已经自定义了同类型 Bean，很多自动配置会因为 `@ConditionalOnMissingBean` 而让用户配置优先。 | 如果自己写了 Bean，Spring Boot 一般会优先用自己写的。 |
| 可以通过 `exclude`、配置属性或自定义 Bean 来关闭或覆盖默认自动配置。 | 不想用某个自动配置时，可以排除掉，或者自己配一个。 |

### 3. Spring Boot Starter 的原理？如何自定义 Starter？

| 标准答案 | 靠记忆又记忆不全的版本 |
|---|---|
| Starter 本质是依赖聚合包，用来把某类功能需要的依赖一次性引入，减少手工管理依赖的成本。 | Starter 就是一组依赖的集合，引一个 starter 就不用一个个引包了。 |
| Starter 通常只负责依赖管理，真正的自动装配逻辑一般放在对应的 autoconfigure 模块中。 | 好像 starter 里面不一定写代码，主要是把自动配置相关依赖带进来。 |
| 自定义 Starter 通常包含两个模块：`xxx-spring-boot-starter` 和 `xxx-spring-boot-autoconfigure`。 | 自定义 starter 一般要建 starter 和 auto configure 两个包。 |
| 在 autoconfigure 模块中编写配置属性类、自动配置类，并用条件注解决定 Bean 是否生效。 | 要写一个配置类，里面创建需要的 Bean，再加一些条件注解。 |
| Spring Boot 2.x 在 `META-INF/spring.factories` 声明自动配置类；Spring Boot 3.x 在 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 声明。 | 还要在 `META-INF` 下面的某个文件里声明自动配置类，不然 Spring Boot 找不到。 |
| 使用方引入 Starter 依赖后，自动配置类被加载，相关 Bean 按条件注册到容器中。 | 别的项目引入这个 starter 后，就能自动把功能配好。 |

### 4. Spring Boot 配置加载顺序？

| 标准答案 | 靠记忆又记忆不全的版本 |
|---|---|
| Spring Boot 配置来源很多，优先级越高的配置会覆盖优先级低的配置。 | Spring Boot 配置有优先级，后面或者更高优先级的会覆盖前面的。 |
| 常见高优先级来源包括命令行参数、系统属性、系统环境变量、外部配置文件、项目内配置文件等。 | 命令行参数、环境变量、配置文件这些都会参与加载。 |
| 通常命令行参数优先级很高，例如 `--server.port=9090` 可以覆盖配置文件中的端口。 | 命令行里写 `--server.port` 一般会覆盖 yml。 |
| 配置文件位置上，外部 `config/` 目录通常优先于外部当前目录，外部配置通常优先于 classpath 内部配置。 | jar 包外面的配置文件一般比 jar 包里面的优先级高。 |
| Profile 配置会叠加在默认配置之上，例如 `application-prod.yml` 覆盖 `application.yml` 中相同属性。 | 开了 prod 之后，`application-prod.yml` 会覆盖默认配置。 |
| 实际排查配置时可以结合 Actuator 的 `/actuator/env` 或启动日志确认最终生效值。 | 看不清哪个配置生效时，可以用 Actuator 或日志看一下。 |

### 5. Spring Boot Actuator 的作用？

| 标准答案 | 靠记忆又记忆不全的版本 |
|---|---|
| Actuator 用于提供生产级应用监控和管理能力，帮助查看应用健康、指标、配置、Bean、线程等运行状态。 | Actuator 主要是用来监控 Spring Boot 应用的。 |
| 常用端点包括 `/actuator/health`、`/actuator/info`、`/actuator/metrics`、`/actuator/env`、`/actuator/beans`。 | 常见接口有 health、info、metrics 这些。 |
| `/health` 可用于健康检查，常被负载均衡、Kubernetes 探针或监控系统调用。 | health 一般用来看服务是不是活着。 |
| `/metrics` 可以暴露 JVM、HTTP 请求、线程、内存、GC 等指标，并可结合 Micrometer 对接 Prometheus 等系统。 | metrics 能看 JVM、接口请求、内存这些指标，也能接 Prometheus。 |
| 生产环境应谨慎暴露端点，通常只开放必要端点，并配合 Spring Security 做访问控制。 | 生产环境不能把所有端点都暴露出去，尤其 env、beans 这些比较敏感。 |
| 可以自定义 `HealthIndicator` 或指标，扩展业务健康检查和监控数据。 | 也可以自己写健康检查，比如检查 Redis、第三方接口。 |

### 6. Spring Boot 如何实现统一异常处理？

| 标准答案 | 靠记忆又记忆不全的版本 |
|---|---|
| 通常使用 `@RestControllerAdvice` 或 `@ControllerAdvice` 配合 `@ExceptionHandler` 实现全局异常处理。 | 一般用 `@ControllerAdvice` 加 `@ExceptionHandler`。 |
| `@RestControllerAdvice` 等价于 `@ControllerAdvice` + `@ResponseBody`，适合 REST API 返回 JSON。 | 如果是接口项目，用 `@RestControllerAdvice` 会直接返回 JSON。 |
| 可以为业务异常、参数校验异常、系统异常分别定义处理方法，返回统一响应结构和 HTTP 状态码。 | 可以分别处理业务异常、参数异常、未知异常。 |
| 对参数校验异常，如 `MethodArgumentNotValidException`，可以提取字段错误信息返回给前端。 | 参数校验失败时，可以把字段错误信息组装一下返回。 |
| 不建议直接把底层异常堆栈或敏感信息返回给客户端，日志中记录详细异常，响应中返回可理解的错误信息。 | 不要把异常堆栈直接返回给前端，日志里记详细点就行。 |
| 统一异常处理能减少 Controller 中重复的 `try-catch`，让接口错误格式更稳定。 | 这样 Controller 里就不用到处写 `try-catch` 了。 |

## 参考资料

- [Spring Boot 官方文档](https://docs.spring.io/spring-boot/reference/)
