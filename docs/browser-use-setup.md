# Browser-Use 部署指南

让 Claude Desktop 获得浏览器自动化能力：打开网页、填表、截图、多步骤交互。

---

## 1. 安装 uvx（Windows 端）

Browser-Use 通过 `uvx` 运行，无需手动创建虚拟环境：

```powershell
# 在 PowerShell 中安装 uv
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

安装后 `uvx.exe` 会出现在你的 Python Scripts 目录下（如 `D:\python3.13\Scripts\uvx.exe`）。

> **验证**：在 PowerShell 中运行 `uvx --version`，应返回版本号。

## 2. 获取 DeepSeek API Key

1. 打开 [DeepSeek 开放平台](https://platform.deepseek.com/)
2. 注册/登录，进入 **API Keys** 页面
3. 点击 **创建 API Key**，复制保存

> 也可以用 OpenAI、Anthropic 等作为 Browser-Use 的驱动模型，只需修改配置中的 `MCP_LLM_PROVIDER` 和对应 API Key。

## 3. 配置 MCP Server

在 `claude_desktop_config.json` 中，替换 `<YOUR_DEEPSEEK_API_KEY>` 并确认 `uvx.exe` 路径：

```json
"browser-use": {
  "command": "D:\\python3.13\\Scripts\\uvx.exe",
  "args": [
    "mcp-server-browser-use@latest"
  ],
  "env": {
    "MCP_LLM_PROVIDER": "deepseek",
    "MCP_LLM_MODEL_NAME": "deepseek-chat",
    "MCP_LLM_BASE_URL": "https://api.deepseek.com",
    "MCP_LLM_API_KEY": "<YOUR_DEEPSEEK_API_KEY>",
    "DEEPSEEK_API_KEY": "<YOUR_DEEPSEEK_API_KEY>",
    "CHROME_PATH": "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "BROWSER_USE_HEADLESS": "false",
    "MCP_AGENT_TOOL_MAX_STEPS": "30",
    "MCP_SERVER_LOGGING_LEVEL": "DEBUG"
  }
}
```

### Chrome 路径说明

> **已知问题**：browser-use MCP server 可能无法直接调用本地已安装的 Chrome，而只能拉起 Playwright 自带的 Chromium Test Shell。

**解决方案**：
1. 删除 `CHROME_PATH` 配置项，让 browser-use 自动使用 Playwright 的 Chromium
2. 或者查阅 [browser-use 官方文档](https://github.com/browser-use/mcp-server) 了解 `USE_OWN_BROWSER` 的正确配置方式

## 4. 验证部署

重启 Claude Desktop，然后说：

> "打开 baidu.com 并截图"

预期：Claude 通过 Browser-Use 打开浏览器，访问百度并返回截图。

如果失败，检查：
- `uvx.exe` 路径是否正确
- DeepSeek API Key 是否有效（账户余额是否充足）
- 网络是否能访问 `api.deepseek.com`
