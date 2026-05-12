# WSL-Exec 部署指南

让 Claude Desktop 获得真实的终端命令执行能力和文件系统访问权限。

---

## 1. 安装 WSL2

以**管理员身份**打开 PowerShell 或命令提示符：

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

## 2. 安装 Ubuntu 发行版

```powershell
wsl --install -d Ubuntu
```

首次启动 Ubuntu 会要求创建用户名和密码。

## 3. 验证 WSL 安装

在 WSL 终端中依次运行以下命令：

```bash
# 验证用户
whoami
# 应显示你刚才创建的用户名

# 验证 WSL 版本
uname -r
# 应显示带有 "WSL2" 的内核版本

# 验证文件互通
ls /mnt/c/ /mnt/d/
# 应显示你的 C 盘和 D 盘内容
```

> **验证通过标志**：以上三条命令都返回正确结果。

## 4. 安装开发工具

### 方式一：一键安装脚本（推荐）

```bash
bash scripts/setup-wsl.sh
```

### 方式二：手动安装

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

# 验证安装
python3 --version
git --version
node --version
npm --version
```

> **验证通过标志**：四个 `--version` 命令都返回版本号。

## 5. 配置 Git 用户信息

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"
```

## 6. 配置 MCP Server

在 `claude_desktop_config.json` 中添加 wsl-exec：

```json
"wsl-exec": {
  "command": "wsl",
  "args": [
    "bash",
    "-ic",
    "npx -y mcp-wsl-exec"
  ],
  "env": {}
}
```

## 7. 验证部署

重启 Claude Desktop，然后说：

> "列出我的 D 盘文件"

预期：Claude 通过 WSL-Exec 执行 `ls /mnt/d/` 并返回 D 盘目录内容。

如果失败，检查：
- WSL 是否正常运行（在终端输入 `wsl` 能否进入 Ubuntu）
- `npx` 是否可用（`which npx`）
