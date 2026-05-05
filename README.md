# Claude Desktop + DeepSeek 完整配置教程

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
- [8. 验证一切正常](#8-验证一切正常)
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

WSL-Exec 让 Claude 能够在你本机的 WSL（Windows Subsystem for Linux）中执行命令。

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
# 从 Microsoft Store 安装 Ubuntu
wsl --install -d Ubuntu
```

首次启动 Ubuntu 会要求创建用户名和密码。建议使用简单的用户名（如你的 Windows 用户名）。

### 5.3 验证 WSL 安装

在 WSL（启动 Ubuntu 终端）中运行：

```bash
whoami
# 应显示你刚才创建的用户名

uname -r
# 应显示带有 "WSL2" 的内核版本

ls /mnt/c/ /mnt/d/
# 应显示你的 C 盘和 D 盘内容
```

### 5.4 安装常用开发工具（在 WSL 内）

```bash
# 更新包列表
sudo apt update && sudo apt upgrade -y

# Python 3（含 pip）
sudo apt install python3 python3-pip -y

# Git
sudo apt install git -y

# Node.js 和 npm（通过 NodeSource）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y

# 验证版本
python3 --version
git --version
node --version
npm --version
```

### 5.5 配置 WSL-Exec MCP Server

WSL-Exec 是一个 MCP Server，让 Claude 通过 MCP 协议调用 WSL 命令。

在 Claude Desktop 的 MCP 配置文件中添加：

```json
{
  "mcpServers": {
    "wsl-exec": {
      "command": "wsl",
      "args": ["bash", "-c", "npx @anthropic/mcp-server-wsl-exec"],
      "env": {}
    }
  }
}
```

> 注意：具体的 MCP Server 包名和配置方式取决于你使用的 WSL-Exec 实现。以上为示例格式，请根据实际包名调整。

### 5.6 验证 WSL-Exec

在 Claude 中执行：

> "列出我的 D 盘根目录"

预期 Claude 能调用 `get_directory_info` 返回 D 盘的内容。

---

## 6. GitHub MCP 部署

GitHub MCP 让 Claude 直接调用 GitHub REST API。

### 6.1 创建 Personal Access Token

1. 打开 [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. 点击 **Generate new token → Generate new token (classic)**
3. 填写 Note（如 `claude-desktop-mcp`）
4. 设置过期时间（建议 90 天或自定义）
5. 勾选以下权限：
   - `repo`（完整仓库访问权限）
   - `workflow`（如果需要操作 GitHub Actions）
   - `read:org`（如果需要访问组织信息）
6. 点击 **Generate token**
7. **立即复制保存** Token（离开页面后无法再次查看）

### 6.2 配置 GitHub MCP

在 Claude Desktop 的 MCP 配置中添加：

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

将 `ghp_xxxxxxxxxxxxxxxxxxxx` 替换为上一步生成的 Token。

### 6.3 验证 GitHub MCP

在 Claude 中执行：

> "搜索 GitHub 上 star 最多的 Python 项目"

预期 Claude 能调用 `search_repositories` 并返回结果。

### 6.4 配置 Git 用户信息（在 WSL 内）

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"
```

这样 WSL-Exec + GitHub MCP 形成完整闭环：API 操作走 GitHub MCP，本地 git 操作走 WSL-Exec。

---

## 7. Browser-Use 部署

Browser-Use 是独立的浏览器自动化 MCP Server，不依赖 Chrome 扩展。

### 7.1 安装依赖

Browser-Use 需要 Python 3.10+ 环境。推荐在 Windows 上或 WSL 内安装。

```bash
# 创建虚拟环境（推荐）
python3 -m venv ~/browser-use-env
source ~/browser-use-env/bin/activate

# 安装 browser-use
pip install browser-use

# 安装 Playwright 浏览器
playwright install chromium
```

### 7.2 配置 API Key

Browser-Use 需要一个 LLM API Key 来驱动浏览器代理。根据你使用的模型配置：

```bash
# 如果用 OpenAI
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"

# 如果用 DeepSeek
export DEEPSEEK_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"

# 如果用 Anthropic
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxx"
```

### 7.3 配置 Browser-Use MCP Server

在 Claude Desktop 的 MCP 配置中添加：

```json
{
  "mcpServers": {
    "browser-use": {
      "command": "python3",
      "args": ["-m", "browser_use.mcp_server"],
      "env": {
        "OPENAI_API_KEY": "sk-xxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

或者在 WSL 中运行：

```json
{
  "mcpServers": {
    "browser-use": {
      "command": "wsl",
      "args": ["bash", "-c", "source ~/browser-use-env/bin/activate && python3 -m browser_use.mcp_server"],
      "env": {
        "OPENAI_API_KEY": "sk-xxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### 7.4 验证 Browser-Use

在 Claude 中执行：

> "打开浏览器，访问 https://www.youtube.com，等搜索框出现后告诉我"

预期 Claude 能调用 `run_browser_agent` 自动完成任务。

---

## 8. 验证一切正常

完成所有部署后，按顺序验证以下场景：

### 8.1 文件系统

```
Claude，在 D 盘创建一个 test 文件夹，里面放一个 hello.py 打印 Hello World，然后运行它
```

预期：创建成功，运行输出 Hello World。

### 8.2 GitHub 全流程

```
Claude，搜索 GitHub 上名为 "awesome-python" 的仓库，告诉我它的 star 数和描述
```

预期：返回仓库的 star 数和描述。

### 8.3 浏览器自动化

```
Claude，打开百度首页，告诉我搜索框出现了没有
```

预期：自动打开百度，确认搜索框已加载。

### 8.4 完整联动

```
Claude，在 GitHub 上搜一个 Python 开源项目，clone 到 D 盘，分析项目结构，然后在浏览器里打开它的官方文档
```

预期：搜索 → clone → 分析 → 打开文档，一气呵成。

---

## 9. 工具路由规则（记忆配置）

部署完成后，需要让 Claude 记住：命令走 WSL，浏览器走 Browser-Use，不要碰自带但不可用的工具。

在 Claude 中执行以下指令（或手动创建 MEMORY.md）：

> "记住以下工具路由规则：所有命令执行走 WSL-Exec（mcp__wsl-exec__*），不用自带的 workspace/bash。所有浏览器交互走 Browser-Use（mcp__browser-use__run_browser_agent / run_deep_research），不用 Claude-in-Chrome。所有 GitHub 操作走 GitHub MCP（mcp__github__*），本地 git 走 WSL。WebSearch 和 WebFetch 照常使用——它们是 API 层面的搜索工具，不受影响。"

这条路由规则的核心逻辑：

```
要执行命令      → WSL-Exec  （不是沙箱 Bash）
要搜信息        → WebSearch / WebFetch  （API 层面，不涉及浏览器）
要操控网页      → Browser-Use  （不是 Claude-in-Chrome）
要操作 GitHub   → GitHub MCP + WSL 本地 git
```

---

## 10. 常见问题

### Q: WSL 命令需要确认怎么办？

A: 危险命令（如 `rm -rf`、涉及系统文件的修改）会触发确认机制。日常操作（创建文件、运行脚本、安装包）通常不需要确认。

### Q: Browser-Use 和 WebSearch 有什么区别？

A: `WebSearch` 是 API 级别的搜索，返回文本结果。`Browser-Use` 是真实的浏览器，可以点击、填表、截图、做多步骤交互。搜索信息用前者，需要"操作网页"才用后者。

### Q: 我的 Token 过期了怎么办？

A: 回到 [GitHub Settings → Tokens](https://github.com/settings/tokens) 重新生成，更新 MCP 配置文件中的 `GITHUB_PERSONAL_ACCESS_TOKEN` 值，重启 Claude Desktop。

### Q: WSL 里的文件和 Windows 怎么互通？

A: WSL 自动将所有 Windows 盘符挂载在 `/mnt/` 下：
- `C:\Users\xuqia\Documents` → `/mnt/c/Users/xuqia/Documents`
- `D:\projects` → `/mnt/d/projects`

在 WSL 中创建的文件会直接出现在 Windows 文件系统中，反之亦然。

### Q: 需要同时装这三个吗？

A: 按需选择：
- 只需要执行命令和读写文件 → 只装 WSL-Exec
- 只需要 GitHub 操作 → 只装 GitHub MCP
- 只需要浏览器自动化 → 只装 Browser-Use
- 完整能力 → 三个都装

它们是互相独立的，不存在依赖关系。

---

## 版本参考

以下是本教程编写时使用的版本（2026 年 5 月）：

| 组件 | 版本 |
|------|------|
| Windows | 10/11，版本 2004+ |
| WSL | 2.x |
| Ubuntu | 22.04 LTS 或 24.04 LTS |
| Python | 3.10+ |
| Git | 2.40+ |
| Node.js | 20.x LTS |
| npm | 10.x |

---

## 许可

MIT License