# Claude Desktop + DeepSeek 完整配置教程

让 Claude Desktop（Cowork 3P Gateway 模式）获得：真实文件系统读写、Git/GitHub 全流程操作、浏览器自动化能力。

> **⚠️ 安全警告：配置文件中包含 API Token 和密钥，切勿将含有真实 Token 的 `claude_desktop_config.json` 提交到 GitHub！本仓库提供的配置文件已脱敏，使用前请替换为你的真实凭证。**

---

## 目录

- [背景](#背景)
- [工具总览](#工具总览)
- [接入前 vs 接入后](#接入前-vs-接入后)
- [快速开始](#快速开始)
- [验证安装](#验证安装)
- [工具路由规则](#工具路由规则)
- [常见问题](#常见问题)
- [更新日志](CHANGELOG.md)

---

## 背景

### 运行环境

本教程针对 **Cowork 3P Gateway 模式**下的 Claude Desktop。

在这个模式下，Claude 自带的以下能力**不可用**：

| 自带的 | 状态 | 原因 |
|--------|------|------|
| `workspace/bash`（沙箱终端） | 不可用 | 隔离的 Linux 容器启动失败 |
| `Claude-in-Chrome`（浏览器操控） | 不可用 | Chrome 扩展在该模式下未连接 |

### 依然可用的自带能力

`WebSearch`、`WebFetch`、`Read`、`Write`、`Edit`、`Glob`、`Grep` 等不依赖沙箱或扩展的工具可正常使用。

### 核心痛点

**能做的**：回答知识性问题、编写代码、通过 WebSearch/WebFetch 获取网络信息、调用已配置的 API。

**不能做的**：直接读写本地文件、执行终端命令、操作 Git 仓库、浏览器自动化、查询系统状态。

**一句话**：Claude 只能做"信息层面"的工作，不能做"执行层面"的工作。

---

## 工具总览

三个 MCP 工具分别解决三个核心问题：

```
┌──────────────────────────────────────────────────────────────┐
│                     Claude Desktop                            │
│                                                              │
│  ┌─────────────────┐ ┌─────────────────┐ ┌────────────────┐ │
│  │   WSL-Exec      │ │   GitHub MCP    │ │  Browser-Use   │ │
│  │                 │ │                 │ │                │ │
│  │ 执行命令、脚本   │ │ 仓库/Issue/PR   │ │ 浏览器自动化    │ │
│  │ 读写真实文件     │ │ API 操作        │ │ 网页交互/截图  │ │
│  │ 系统查询        │ │ 代码搜索        │ │ 深度调研       │ │
│  │ 本地 Git        │ │ 文件管理        │ │                │ │
│  └─────────────────┘ └─────────────────┘ └────────────────┘ │
│         ↓                    ↓                   ↓          │
│  解决：无法执行      解决：Git 全流程    解决：无法操控      │
│  终端操作、无法      + 平台 API 整合    浏览器               │
│  访问真实文件                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 接入前 vs 接入后

| 任务 | 接入前 | 接入后 |
|------|--------|--------|
| 在 D 盘创建项目文件夹 | 做不到 | `mkdir -p /mnt/d/my-project` |
| 运行 Python 脚本 | 做不到 | `python3 /mnt/d/script.py` |
| 安装 pip 包 | 做不到 | `python3 -m pip install requests` |
| `git clone` + `git push` | 做不到 | 直接在真实项目中操作 |
| 打开网页截图 | 做不到 | `run_browser_agent("打开 XX 网站截图")` |
| 磁盘满了检查空间 | 做不到 | `get_disk_usage` |

**一个完整工作流的变化**：从"你手动 clone 下来然后把文件传给我"变成 Claude 搜索 → clone → 分析 → 输出报告，一条指令全程自动完成。

---

## 快速开始

### 前提条件

- **操作系统**：Windows 10 版本 2004+（内部版本 19041+）或 Windows 11
- **Claude Desktop**：已安装，Cowork 3P Gateway 模式
- **管理员权限**：安装 WSL 需要
- **GitHub 账号**：用于生成 Personal Access Token

### 步骤一：安装 WSL2 + 开发环境

**一键安装**（推荐）：

```powershell
# 在 PowerShell（管理员）中运行
wsl --install -d Ubuntu
```

然后进入 WSL 终端，运行本仓库提供的安装脚本：

```bash
bash scripts/setup-wsl.sh
```

详细步骤见：[WSL-Exec 部署指南](docs/wsl-exec-setup.md)

### 步骤二：配置 GitHub MCP

1. [创建 GitHub Personal Access Token](https://github.com/settings/tokens)（需要 `repo`、`workflow`、`read:org` 权限）
2. 将 Token 填入配置文件

详细步骤见：[GitHub MCP 部署指南](docs/github-mcp-setup.md)

### 步骤三：配置 Browser-Use

1. [获取 DeepSeek API Key](https://platform.deepseek.com/)
2. 将 API Key 填入配置文件

详细步骤见：[Browser-Use 部署指南](docs/browser-use-setup.md)

### 步骤四：替换配置文件

1. 找到你的 `claude_desktop_config.json`（在 `%LOCALAPPDATA%\Claude-3p\` 下）
2. 用本仓库的 [claude_desktop_config.json](claude_desktop_config.json) 内容替换
3. 将 `<YOUR_GITHUB_TOKEN>` 和 `<YOUR_DEEPSEEK_API_KEY>` 替换为你的真实凭证
4. **重启 Claude Desktop**

---

## 验证安装

部署完成后，在 Claude Desktop 中说以下命令逐项验证：

| 工具 | 验证命令 | 预期结果 |
|------|----------|----------|
| WSL-Exec | "列出我的 D 盘文件" | 显示 D 盘目录内容 |
| WSL-Exec | "查看我的 Git 版本" | 显示 `git version 2.40+` |
| GitHub MCP | "列出我的 GitHub 仓库" | 显示你的仓库列表 |
| Browser-Use | "打开 baidu.com 并截图" | 返回百度首页截图 |

如果某项验证失败，请查看对应的部署指南和 [FAQ](docs/faq.md)。

---

## 工具路由规则

部署完成后，让 Claude 记住工具优先级：

> "记住以下工具路由规则：所有命令执行走 WSL-Exec。所有浏览器交互走 Browser-Use。所有 GitHub 操作走 GitHub MCP，本地 git 走 WSL。WebSearch 和 WebFetch 照常使用。"

```
要执行命令      → WSL-Exec
要搜信息        → WebSearch / WebFetch
要操控网页      → Browser-Use
要操作 GitHub   → GitHub MCP + WSL 本地 git
```

---

## 常见问题

常见问题解答见 [FAQ](docs/faq.md)，包括：

- 配置文件改完后不生效
- WSL 命令总是需要确认
- Browser-Use 和 WebSearch 的区别
- GitHub Token 过期处理
- WSL 和 Windows 文件互通
- 能否只装部分工具
- Browser-Use 无法使用本地 Chrome

---

## 版本参考（2026 年 5 月）

| 组件 | 版本要求 |
|------|----------|
| Windows | 10 2004+ 或 11 |
| WSL | 2.x |
| Ubuntu | 22.04 / 24.04 LTS |
| Python | 3.10+ |
| Git | 2.40+ |
| Node.js | 20.x LTS |

---

## 许可

MIT License
