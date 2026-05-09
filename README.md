# Multi-Model Agent Workflow Lab

 Public validation branch for multi-model coding-agent workflows with Codex-compatible routing, Claude Desktop, DeepSeek, MCP tools, WSL execution, GitHub automation, browser automation, and skill-based developer workflows.

## Project Status

This repository is an early public validation branch for a broader multi-model coding-agent platform. Maintainer context: the platform is being developed by a 15-person team, and this repository is maintained by one of its core developers.

The goal is to explore practical coding-agent workflows that can integrate Codex, Claude, DeepSeek, and other major models through MCP servers, skill routing, shell execution, GitHub automation, browser automation, and reproducible evaluation tasks.

The current repository focuses on setup documentation, tool routing, MCP integration, and real-world workflow testing. A broader public release is planned around mid-May 2026.

## What This Repository Provides

- Claude Desktop + DeepSeek setup guide
- WSL-based command execution workflow
- GitHub MCP integration
- Browser-Use automation setup
- Sanitized configuration examples
- Tool routing rules for coding agents
- Planned Codex-compatible workflow examples
- Planned skill-based agent templates
- Planned reproducible evaluation tasks

## Why This Matters

Modern coding agents need more than text generation. They need controlled access to local files, shell execution, repository operations, browser automation, model routing, and reproducible workflows.

This repository documents an early public testing layer for a system that aims to make multi-model coding agents easier to configure, evaluate, and extend.

## For OpenAI Codex for OSS Reviewers

This repository is new and currently has limited public GitHub activity, but it is intended to reflect active development rather than final project maturity.

The purpose of this repository is to become a public validation branch for Codex-compatible agent workflows, including:

- code generation workflows
- refactoring workflows
- test generation workflows
- issue triage workflows
- pull request review assistance
- documentation generation
- MCP tool integration
- browser automation
- skill-based routing
- safe local execution patterns

If granted API credits or Codex access, the project plan is to use them to build reproducible open examples and improve the public release of this project.

## Experimental Multimodal Skill Pipeline

We are experimenting with multimodal skill pipelines that allow text-centric models to perform visual-understanding tasks through external perception tools, browser automation, structured reasoning workflows, and tool-assisted observation.

This repository does not claim benchmark parity with any commercial model. The goal is to document practical engineering workflows, not to make unsupported performance claims.

## Safety Boundary

This repository may document workflows that involve local shell execution, browser automation, GitHub API access, and LLM API credentials. Examples should remain placeholder-based and reproducible. Do not commit real API keys, browser cookies, local session files, or private configuration.

Commands that write files, install packages, automate browsers, or call external APIs should be reviewed before execution and should use the minimum required permissions.

## Repository Structure

```text
.
|-- README.md
|-- ROADMAP.md
|-- CONTRIBUTING.md
|-- SECURITY.md
|-- .gitignore
|-- claude_desktop_config.json
`-- examples/
    |-- codex-workflows/
    |-- claude-desktop-workflows/
    |-- mcp-routing/
    |-- browser-automation/
    |-- github-automation/
    `-- multimodal-skill-pipeline/
```

## Planned GitHub Issues

Suggested issues for early public tracking:

- Add Codex-compatible workflow examples
- Add MCP skill routing template
- Add security checklist for local command execution
- Add GitHub issue triage example
- Add pull request review workflow example
- Add browser automation reproducibility notes
- Add multimodal skill pipeline example
- Add Windows/WSL troubleshooting matrix
- Add benchmark-style evaluation tasks
- Add release checklist for v0.1.0-public-validation

---

# Legacy Setup Guide: Claude Desktop + DeepSeek

让 Claude Desktop（Cowork 3P Gateway 模式）获得：真实文件系统读写、Git/GitHub 全流程操作、浏览器自动化能力。

---

## 目录

- [1. 背景：为什么需要这些工具](#1-背景为什么需要这些工具)
- [2. 工具总览](#2-工具总览)
- [3. 接入前 vs 接入后](#3-接入前-vs-接入后)
- [4. 前提条件](#4-前提条件)
- [5. WSL-Exec 部署](#5-wsl-exec-部署)
- [6. GitHub MCP 部署](#6-github-mcp-部署)
- [7. Browser-Use 部署](#7-browser-use-部署)
- [8. 最终配置文件](#8-最终配置文件)
- [9. 工具路由规则（记忆配置）](#9-工具路由规则记忆配置)
- [10. 常见问题](#10-常见问题)

---

## 1. 背景：为什么需要这些工具

### 运行环境

本教程针对 **Cowork 3P Gateway 模式**下的 Claude Desktop（简称 Claude）。

在这个模式下，Claude 自带的以下能力**不可用**：

| 自带的 | 状态 | 原因 |
|--------|------|------|
| `workspace/bash`（沙箱终端） | 不可用 | 隔离的 Linux 容器启动失败 |
| `Claude-in-Chrome`（浏览器操控） | 不可用 | Chrome 扩展在该模式下未连接 |

### 依然可用的自带能力

以下工具不依赖沙箱或扩展，可正常使用：

- `WebSearch` / `WebFetch`：搜索网络和抓取网页内容
- `Read` / `Write` / `Edit`：文件读写（但仅限临时目录）
- `Glob` / `Grep`：代码搜索
- GitHub MCP：如果已配置，API 层操作可用

### 核心痛点

在没有这三件工具时，Claude 能做的事情和不能做的事情：

**能做的**：
- 回答知识性问题、编写代码、解释概念
- 创建文件（但只能放在临时 outputs 目录，需要手动下载）
- 通过 WebSearch/WebFetch 获取网络信息
- 调用已配置的 API（如 GitHub MCP 的 Issue/PR 管理）

**不能做的**：
- 直接读写你电脑上的任意文件（C 盘、D 盘）
- 执行终端命令（`pip install`、`npm run`、`python` 等）
- 运行和调试代码
- 操作 Git 仓库（`git clone`、`git commit`、`git push`）
- 打开浏览器做自动化操作（填表、截图、多步骤交互）
- 查询系统状态（磁盘空间、进程列表、环境变量）

**一句话**：Claude 只能做"信息层面"的工作，不能做"执行层面"的工作。

---

## 2. 工具总览

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

## 3. 接入前 vs 接入后

### 场景对比

| 任务 | 接入前 | 接入后 |
|------|--------|--------|
| 在 D 盘创建项目文件夹 | 做不到（沙箱无法访问 D 盘） | `mkdir -p /mnt/d/my-project` |
| 运行 Python 脚本 | 做不到（沙箱 Bash 不可用） | `python3 /mnt/d/script.py` |
| 安装 pip 包 | 做不到 | `python3 -m pip install requests` |
| `git clone` 仓库到本地 | 做不到 | `git clone` 到 `/mnt/d/` 下 |
| `git commit` + `git push` | 做不到 | 直接在真实项目中操作 |
| 在 GitHub 创建 Issue | 可以（如果有 API Token） | 可以，且能配合本地 git |
| 打开网页截图 | 做不到（Chrome 扩展未连接） | `run_browser_agent("打开 XX 网站截图")` |
| 搜索最新技术文档 | 可以（WebSearch） | 可以，且能用浏览器验证 |
| 磁盘满了检查空间 | 做不到 | `get_disk_usage` |
| 查看正在运行的进程 | 做不到 | `list_processes` |

### 一个完整工作流的变化

**接入前**：你说"帮我看看 GitHub 上最火的 AI 项目，clone 一个下来分析一下代码结构" → Claude 只能搜索 GitHub API 列出项目，然后说"你手动 clone 下来然后把文件传给我"。

**接入后**：Claude 搜索 GitHub → 找到目标仓库 → `git clone` 到 D 盘 → 用 `ls`/`tree` 分析目录结构 → 逐文件阅读分析 → 输出报告。一条指令全程自动完成。

---

## 4. 前提条件

开始前请确认以下条件：

- **操作系统**：Windows 10 版本 2004+（内部版本 19041+）或 Windows 11
- **Claude Desktop**：已安装，Cowork 3P Gateway 模式
- **管理员权限**：安装 WSL 需要
- **网络**：能够访问 GitHub、PyPI
- **GitHub 账号**：用于生成 Personal Access Token

---

## 5. WSL-Exec 部署

### 5.1 安装 WSL2

以管理员身份打开 PowerShell 或命令提示符：

```powershell
# 一键安装 WSL2 + Ubuntu
wsl --install -d Ubuntu
```

如果上述命令失败，手动启用所需功能：

```powershell
# 启用 WSL 功能
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 启用虚拟机平台
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 重启电脑
shutdown /r /t 0
```

重启后，设置 WSL2 为默认版本：

```powershell
wsl --set-default-version 2
```

### 5.2 安装 Ubuntu 发行版

```powershell
wsl --install -d Ubuntu
```

首次启动 Ubuntu 会要求创建用户名和密码。

### 5.3 验证 WSL 安装

在 WSL 终端中运行：

```bash
whoami
# 应显示你刚才创建的用户名

uname -r
# 应显示带有 "WSL2" 的内核版本

ls /mnt/c/ /mnt/d/
# 应显示你的 C 盘和 D 盘内容
```

### 5.4 安装常用开发工具

```bash
# 更新包列表
sudo apt update && sudo apt upgrade -y

# Python 3
sudo apt install python3 python3-pip -y

# Git
sudo apt install git -y

# Node.js 和 npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y

# 验证
python3 --version
git --version
node --version
npm --version
```

### 5.5 配置 Git 用户信息

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"
```

---

## 6. GitHub MCP 部署

### 6.1 创建 Personal Access Token

1. 打开 [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. 点击 **Generate new token → Generate new token (classic)**
3. 填写 Note（如 `claude-desktop-mcp`）
4. 设置过期时间（建议 90 天）
5. 勾选以下权限：
   - `repo`（完整仓库访问权限）
   - `workflow`（如需 GitHub Actions）
   - `read:org`（如需访问组织信息）
6. 点击 **Generate token**
7. **立即复制保存** Token（离开页面后无法再次查看）

---

## 7. Browser-Use 部署

### 7.1 安装 uvx（Windows 端）

Browser-Use 通过 `uvx` 运行，无需手动创建虚拟环境：

```powershell
# 在 PowerShell 中安装 uv
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

安装后 `uvx.exe` 会出现在你的 Python Scripts 目录下（如 `D:\python3.13\Scripts\uvx.exe`）。

### 7.2 获取 DeepSeek API Key

1. 打开 [DeepSeek 开放平台](https://platform.deepseek.com/)
2. 注册/登录，进入 **API Keys** 页面
3. 点击 **创建 API Key**，复制保存

> 也可以用 OpenAI、Anthropic 等作为 Browser-Use 的驱动模型，只需修改配置中的 `MCP_LLM_PROVIDER` 和对应 API Key。

---

## 8. 最终配置文件

### 8.1 配置文件位置

Claude Desktop 的 MCP 配置文件位于：

```
C:\Users\<你的用户名>\AppData\Local\Claude-3p\
  └── local-agent-mode-sessions\
      └── d375d661-6dbb-408e-9969-402193c8f3a5\
          └── 00000000-0000-4000-8000-000000000001\
              └── local_<随机ID>\
                  └── uploads\
                      └── claude_desktop_config.json
```

最快的找到方式：在 Claude Desktop 中直接说「帮我找到 claude_desktop_config.json 文件的位置」，Claude 会返回完整路径。

### 8.2 需要替换的内容

打开配置文件后，搜索并替换以下三项：

| 搜索（原值关键特征） | 替换为 |
|---------------------|--------|
| `ghp_` 开头的 GitHub Token | 你的 GitHub Personal Access Token |
| `sk-` 开头的 DeepSeek API Key（在 `MCP_LLM_API_KEY` 和 `DEEPSEEK_API_KEY` 两处） | 你的 DeepSeek API Key |
| `D:\\python3.13\\Scripts\\uvx.exe`（如果你的 Python 不在这个路径） | 你的 uvx.exe 实际路径 |

**替换后重启 Claude Desktop 即可生效。**

### 8.3 完整配置参考

以下是本仓库提供的脱敏版配置文件：[claude_desktop_config.json](claude_desktop_config.json)

你可以直接复制这个文件的内容，粘贴到你的配置文件中，然后替换三个占位符。

配置文件结构说明：

```json
{
  "mcpServers": {
    "github":        // GitHub MCP — 通过 WSL 运行
    "wsl-exec":      // WSL-Exec — 终端命令执行  
    "browser-use":   // Browser-Use — 浏览器自动化
  },
  "deploymentMode": "3p",    // Cowork 3P Gateway 模式
  "preferences": { ... }     // UI 偏好设置
}
```

**各 MCP Server 的关键配置说明**：

| 配置项 | 所属 | 说明 |
|--------|------|------|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | github | GitHub 个人访问令牌，格式 `ghp_xxx` |
| `MCP_LLM_PROVIDER` | browser-use | 驱动浏览器代理的 LLM，示例用 `deepseek` |
| `MCP_LLM_API_KEY` | browser-use | LLM 的 API Key |
| `DEEPSEEK_API_KEY` | browser-use | DeepSeek 专用 Key（与上面相同） |
| `CHROME_PATH` | browser-use | Chrome 浏览器路径 |
| `BROWSER_USE_HEADLESS` | browser-use | `false` 表示显示浏览器窗口（调试用） |
| `USE_OWN_BROWSER` | browser-use | `True` 使用本地已安装的 Chrome |

---

## 9. 工具路由规则（记忆配置）

部署完成后，让 Claude 记住工具优先级。

在 Claude 中执行：

> "记住以下工具路由规则：所有命令执行走 WSL-Exec，不用自带的 workspace/bash。所有浏览器交互走 Browser-Use，不用 Claude-in-Chrome。所有 GitHub 操作走 GitHub MCP，本地 git 走 WSL。WebSearch 和 WebFetch 照常使用。"

核心逻辑：

```
要执行命令      → WSL-Exec
要搜信息        → WebSearch / WebFetch
要操控网页      → Browser-Use
要操作 GitHub   → GitHub MCP + WSL 本地 git
```

---

## 10. 常见问题

### Q: 配置文件改完后 Claude 没变化？

A: 重启 Claude Desktop。如果仍然无效，检查 Token 是否已过期、路径是否正确。

### Q: WSL 命令总是需要确认？

A: 危险命令（如 `rm -rf`、操作系统文件）会触发确认。日常操作（创建文件、运行脚本、安装包）通常不需要确认。

### Q: Browser-Use 和 WebSearch 有什么区别？

A: `WebSearch` 是 API 级别的搜索，返回文本结果。`Browser-Use` 是真实的浏览器，可以点击、填表、截图、做多步骤交互。搜索信息用前者，需要"操作网页"才用后者。

### Q: GitHub Token 过期了怎么办？

A: 到 [GitHub Settings → Tokens](https://github.com/settings/tokens) 重新生成，更新配置文件，重启 Claude Desktop。

### Q: WSL 文件和 Windows 怎么互通？

A: WSL 自动挂载 Windows 盘符到 `/mnt/`：
- `C:\Users\xxx\Documents` → `/mnt/c/Users/xxx/Documents`
- `D:\projects` → `/mnt/d/projects`

### Q: 需要三个都装吗？

A: 按需选择，互相独立：
- 只要终端和文件 → WSL-Exec
- 只要 GitHub → GitHub MCP
- 只要浏览器 → Browser-Use
- 完整能力 → 三个都装

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
