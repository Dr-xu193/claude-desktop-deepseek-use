# GitHub MCP 部署指南

让 Claude Desktop 获得 GitHub 全流程操作能力：仓库管理、Issue/PR 操作、代码搜索。

---

## 1. 创建 Personal Access Token

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

## 2. 配置 MCP Server

在 `claude_desktop_config.json` 中，将 `<YOUR_GITHUB_TOKEN>` 替换为你刚创建的 Token：

```json
"github": {
  "command": "wsl",
  "args": [
    "bash",
    "-ic",
    "GITHUB_PERSONAL_ACCESS_TOKEN=<YOUR_GITHUB_TOKEN> npx -y @modelcontextprotocol/server-github"
  ],
  "env": {}
}
```

## 3. 验证部署

重启 Claude Desktop，然后依次说：

> "列出我的 GitHub 仓库"

预期：Claude 列出你账号下的仓库。

> "查看仓库 claude-desktop-deepseek-use 的 README"

预期：Claude 读取并显示该仓库的 README 内容。

## 4. 常见问题

- **Token 权限不足**：确保勾选了 `repo` 权限
- **Token 过期**：到 GitHub Settings 重新生成，更新配置文件，重启 Claude Desktop
- **网络问题**：确认能正常访问 `github.com`
