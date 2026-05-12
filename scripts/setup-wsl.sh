#!/bin/bash
# ===========================================================
# WSL 开发环境一键安装脚本
# 用于 Claude Desktop + DeepSeek 配置教程
# ===========================================================
set -e

echo "========================================="
echo "  WSL 开发环境安装脚本"
echo "========================================="

# 更新包列表
echo ""
echo "[1/4] 更新包列表..."
sudo apt update && sudo apt upgrade -y

# 安装 Python 3
echo ""
echo "[2/4] 安装 Python 3..."
sudo apt install python3 python3-pip -y

# 安装 Git
echo ""
echo "[3/4] 安装 Git..."
sudo apt install git -y

# 安装 Node.js 和 npm
echo ""
echo "[4/4] 安装 Node.js 20.x LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y

# 验证安装
echo ""
echo "========================================="
echo "  安装完成！版本信息："
echo "========================================="
echo "Python:  $(python3 --version 2>&1)"
echo "pip:     $(pip3 --version 2>&1 | head -1)"
echo "Git:     $(git --version 2>&1)"
echo "Node.js: $(node --version 2>&1)"
echo "npm:     $(npm --version 2>&1)"
echo ""
echo "接下来请配置 Git 用户信息："
echo "  git config --global user.name \"你的GitHub用户名\""
echo "  git config --global user.email \"你的GitHub邮箱\""
echo ""
echo "========================================="
