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

1. Spring Boot 自动配置原理？
2. Spring Boot Starter 的原理？如何自定义 Starter？
3. Spring Boot 配置加载顺序？
4. Spring Boot Actuator 的作用？
5. Spring Boot 如何实现统一异常处理？

## 参考资料

- [Spring Boot 官方文档](https://docs.spring.io/spring-boot/reference/)
