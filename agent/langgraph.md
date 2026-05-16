---
layout: page
title: "LangGraph"
permalink: /agent/langgraph/
category: Agent 开发
---

## 概述

LangGraph 是 LangChain 团队推出的 Agent 编排框架，基于图（Graph）结构构建有状态、可循环的多步骤 AI 工作流，支持复杂 Agent 系统的开发。

## 核心概念

### State（状态）
- 整个图共享的状态对象
- 使用 TypedDict 定义
- 通过 reducer 函数定义状态更新规则

```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import add_messages

class State(TypedDict):
    messages: Annotated[list, add_messages]  # 对话消息列表
    next_action: str                         # 下一步动作
```

### Node（节点）
- 每个节点是一个函数，接收当前 State，返回 State 更新

```python
def chatbot(state: State):
    response = llm.invoke(state["messages"])
    return {"messages": [response]}
```

### Edge（边）
- **普通边**：从一个节点到另一个节点
- **条件边**：根据状态决定路由到哪个节点

```python
# 普通边
graph.add_edge("start", "chatbot")

# 条件边
graph.add_conditional_edges("chatbot", route_function, {
    "tools": "tools",
    "end": END
})
```

## 基础示例：对话 Agent

```python
from langgraph.graph import StateGraph, START, END

# 1. 定义状态
class State(TypedDict):
    messages: Annotated[list, add_messages]

# 2. 定义节点函数
def chatbot(state: State):
    response = llm.invoke(state["messages"])
    return {"messages": [response]}

def should_continue(state: State):
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tools"
    return END

# 3. 构建图
graph = StateGraph(State)
graph.add_node("chatbot", chatbot)
graph.add_node("tools", tool_node)

graph.add_edge(START, "chatbot")
graph.add_conditional_edges("chatbot", should_continue)
graph.add_edge("tools", "chatbot")

# 4. 编译运行
app = graph.compile()
result = app.invoke({"messages": [HumanMessage(content="北京天气如何？")]})
```

## 高级特性

### 1. Human-in-the-Loop（人工干预）

```python
# 编译时指定断点
app = graph.compile(interrupt_before=["human_review"])

# 运行到断点暂停
result = app.invoke(input)

# 人工审核后继续
app.invoke(None, config={"configurable": {"thread_id": "1"}})
```

### 2. 持久化

```python
from langgraph.checkpoint.memory import MemorySaver

checkpointer = MemorySaver()
app = graph.compile(checkpointer=checkpointer)

# 每次调用传入 thread_id
config = {"configurable": {"thread_id": "thread-1"}}
result = app.invoke({"messages": [HumanMessage("你好")]}, config)

# 后续对话继续同一 thread
result = app.invoke({"messages": [HumanMessage("接着聊")]}, config)
```

### 3. 流式输出

```python
# 流式输出 token
for chunk in app.stream({"messages": [HumanMessage("写一首诗")]}, config):
    print(chunk)
```

### 4. 多 Agent 协作

```python
# Supervisor 模式：一个主 Agent 调度子 Agent
def supervisor(state: State):
    # 决定调用哪个子 Agent
    next_agent = llm_with_tools.invoke(state["messages"])
    return {"next_action": next_agent}

# 定义子 Agent 节点
graph.add_node("researcher", researcher_agent)
graph.add_node("coder", coder_agent)
graph.add_node("supervisor", supervisor)

graph.add_conditional_edges("supervisor", lambda s: s["next_action"], {
    "researcher": "researcher",
    "coder": "coder",
    "end": END
})
```

## 常见 Agent 架构

### ReAct Agent
```
用户输入 → LLM 思考 → 选择工具 → 执行 → 观察 → 继续思考 → 最终回答
```

### Multi-Agent 架构
| 模式 | 说明 |
|------|------|
| Supervisor | 一个主 Agent 调度多个子 Agent |
| Swarm | Agent 之间直接交接控制权 |
| Hierarchical | 多层 Supervisor 嵌套 |

### 规划型 Agent
```
用户输入 → 制定计划 → 逐步执行 → 检查结果 → 修正 → 完成
```

## LangGraph vs LangChain

| 特性 | LangChain | LangGraph |
|------|-----------|-----------|
| 核心抽象 | Chain（链） | Graph（图） |
| 流程控制 | 线性管道 | 任意拓扑（含循环） |
| 状态管理 | 无内置状态 | 内置 State + Checkpoint |
| 适用场景 | 简单链式调用 | 复杂 Agent 工作流 |
| 人工干预 | 不原生支持 | 原生支持 |

## 常见面试题

1. LangGraph 的核心概念（State、Node、Edge）？
2. LangGraph 和 LangChain 的区别？
3. 如何实现 Human-in-the-Loop？
4. 常见的 Multi-Agent 架构模式？
5. LangGraph 如何实现状态持久化？

## 参考资料

- [LangGraph 官方文档](https://langchain-ai.github.io/langgraph/)
- [LangGraph GitHub](https://github.com/langchain-ai/langgraph)
