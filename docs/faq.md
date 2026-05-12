# 常见问题 (FAQ)

---

### Q: 配置文件改完后 Claude 没变化？

A: **重启 Claude Desktop**。如果仍然无效：
1. 检查 JSON 格式是否正确（可以用 [JSONLint](https://jsonlint.com/) 验证）
2. 确认 Token 是否已过期
3. 确认路径是否正确（尤其是 `uvx.exe` 的路径）
4. 查看 Claude Desktop 的日志文件

---

### Q: WSL 命令总是需要确认？

A: 危险命令（如 `rm -rf`、操作系统文件）会触发确认。日常操作（创建文件、运行脚本、安装包）通常不需要确认。

你可以在 Claude 中说"允许 wsl 命令"来减少确认频率。

---

### Q: Browser-Use 和 WebSearch 有什么区别？

A: 

| 特性 | WebSearch | Browser-Use |
|------|-----------|-------------|
| 原理 | API 级别搜索 | 真实浏览器操控 |
| 返回内容 | 文本结果 | 可点击、填表、截图 |
| 适用场景 | 搜索信息、查资料 | 需要操作网页的交互 |
| 速度 | 快 | 较慢 |

**规则**：搜索信息用 WebSearch，需要"操作网页"（填表、截图、多步骤交互）才用 Browser-Use。

---

### Q: GitHub Token 过期了怎么办？

A: 
1. 到 [GitHub Settings → Tokens](https://github.com/settings/tokens) 重新生成
2. 更新配置文件中的 `GITHUB_PERSONAL_ACCESS_TOKEN`
3. 重启 Claude Desktop

---

### Q: WSL 文件和 Windows 怎么互通？

A: WSL 自动挂载 Windows 盘符到 `/mnt/`：
- `C:\Users\xxx\Documents` → `/mnt/c/Users/xxx/Documents`
- `D:\projects` → `/mnt/d/projects`

在 WSL 中可以直接读写这些路径。

---

### Q: 需要三个都装吗？

A: 按需选择，互相独立：
- 只要终端和文件操作 → 只装 WSL-Exec
- 只要 GitHub 操作 → 只装 GitHub MCP
- 只要浏览器操控 → 只装 Browser-Use
- 完整能力 → 三个都装

---

### Q: Browser-Use 无法使用本地 Chrome，只能拉起 Chromium Test Shell？

A: 这是 browser-use MCP server 的一个已知问题。目前的解决方案：

1. **使用 Playwright 自带的 Chromium**：删除 `CHROME_PATH` 相关配置项，让 browser-use 自动下载并使用 Playwright 的 Chromium
2. **检查环境变量**：确保 `USE_OWN_BROWSER=true` 且 Chrome 路径正确
3. **查阅官方文档**：[browser-use MCP Server](https://github.com/browser-use/mcp-server) 了解最新配置方式

如果你成功对接了本地 Chrome，欢迎提交 PR！

---

### Q: 配置文件中的 Token 占位符在哪里？

A: 在 `claude_desktop_config.json` 中搜索：
- `<YOUR_GITHUB_TOKEN>` → 替换为 GitHub Personal Access Token
- `<YOUR_DEEPSEEK_API_KEY>` → 替换为 DeepSeek API Key

---

### Q: 安装脚本运行失败怎么办？

A: 
1. 确认以 **WSL 终端** 运行（不是 Windows PowerShell）
2. 确认网络连接正常
3. 手动执行脚本中的命令，逐行排查错误
