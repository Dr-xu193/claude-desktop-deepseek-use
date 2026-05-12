# 更新日志

## [1.1.0] - 2026-05-12

### 新增
- 添加 `docs/wsl-exec-setup.md` — WSL-Exec 详细部署指南
- 添加 `docs/github-mcp-setup.md` — GitHub MCP 详细部署指南
- 添加 `docs/browser-use-setup.md` — Browser-Use 详细部署指南
- 添加 `docs/faq.md` — 常见问题独立文档
- 添加 `scripts/setup-wsl.sh` — WSL 开发环境一键安装脚本
- 添加 `CHANGELOG.md` — 版本更新记录

### 改进
- 重构 README.md：缩减篇幅，提取详细内容到独立文档
- 在 README 中添加安全警告（Token 保护）
- 为每个部署流程添加验证步骤
- 配置文件占位符改为英文大写格式（`<YOUR_GITHUB_TOKEN>`）
- 修复 Browser-Use Chrome 配置的已知问题说明

### 修复
- 移除 `claude_desktop_config.json` 中的 `_comment_chrome_path` 临时字段
- 修复浏览器配置中的 Chrome 路径问题，添加替代方案

---

## [1.0.0] - 2026-05-05

### 新增
- 初始版本：Claude Desktop + DeepSeek 配置教程
- WSL-Exec、GitHub MCP、Browser-Use 三大工具的接入文档
- `claude_desktop_config.json` 配置文件模板
