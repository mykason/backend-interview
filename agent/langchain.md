---
layout: page
title: "LangChain"
permalink: /agent/langchain/
category: Agent 开发
---

## 概述

LangChain 是一个用于构建 LLM 应用的开发框架，提供了模型调用、提示词管理、链式调用、记忆、工具调用、RAG 等核心抽象，加速 AI 应用开发。

## 核心模块

### 1. Model I/O（模型交互）

#### Chat Models
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4", temperature=0)
response = llm.invoke("什么是向量数据库？")
```

#### Prompt Templates
```python
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个{role}。"),
    ("human", "{question}")
])

chain = prompt | llm
response = chain.invoke({"role": "技术专家", "question": "解释微服务架构"})
```

### 2. Chains（链）

#### LCEL（LangChain Expression Language）
- 使用 `|` 管道操作符组合组件
- 支持流式输出、批处理、异步

```python
chain = prompt | llm | output_parser
result = chain.invoke({"role": "助手", "question": "你好"})
```

### 3. RAG（检索增强生成）

#### 基本流程
```
文档 → 分割 → Embedding → 向量存储 → 检索 → 注入 Prompt → LLM 生成
```

#### 文档加载与分割
```python
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter

loader = TextLoader("knowledge.txt")
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
chunks = splitter.split_documents(docs)
```

#### 向量存储
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(chunks, OpenAIEmbeddings())
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})
```

#### RAG Chain
```python
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

template = """基于以下上下文回答问题：
{context}

问题：{question}
"""
rag_prompt = ChatPromptTemplate.from_template(template)

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | rag_prompt
    | llm
    | StrOutputParser()
)

response = rag_chain.invoke("什么是微服务？")
```

### 4. Agents（智能体）

#### Tool 定义
```python
from langchain_core.tools import tool

@tool
def search_weather(city: str) -> str:
    """查询指定城市的天气"""
    # 实际调用天气 API
    return f"{city}今天晴，25°C"

@tool
def calculate(expression: str) -> str:
    """计算数学表达式"""
    return str(eval(expression))
```

#### ReAct Agent
```python
from langchain.agents import create_react_agent

tools = [search_weather, calculate]
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

result = agent_executor.invoke({"input": "北京天气如何？"})
```

### 5. Memory（记忆）

#### 对话历史管理
```python
from langchain_core.messages import HumanMessage, AIMessage
from langgraph.graph.message import add_messages

# 使用消息列表管理对话历史
messages = [
    HumanMessage(content="你好"),
    AIMessage(content="你好！有什么可以帮你的？"),
]
```

## 与 LangGraph 的关系

- **LangChain**：提供基础组件（模型、工具、提示词）
- **LangGraph**：在 LangChain 之上提供有状态的 Agent 编排

## 常见面试题

1. LangChain 的核心模块有哪些？
2. RAG 的原理和实现流程？
3. LCEL 管道操作符的优势？
4. Agent 和 Chain 的区别？
5. 如何优化 RAG 的检索效果？

## 参考资料

- [LangChain 官方文档](https://python.langchain.com/)
- [LangChain GitHub](https://github.com/langchain-ai/langchain)
