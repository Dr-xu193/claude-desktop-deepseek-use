# Security Policy

This project involves local command execution, browser automation, GitHub API access, MCP servers, and LLM API credentials. Please follow the safety rules below.

## Never Commit Secrets

Do not commit:

- GitHub Personal Access Tokens
- OpenAI API keys
- DeepSeek API keys
- Anthropic API keys
- Browser cookies
- Local session files
- Claude Desktop private configuration files
- MCP server credentials
- `.env` files
- Local browser profiles

## Recommended Practices

- Use environment variables whenever possible.
- Use placeholder values in configuration examples.
- Restrict token scopes to the minimum required permissions.
- Rotate tokens regularly.
- Review commands before allowing an agent to execute them.
- Avoid running destructive commands through automated agents.
- Avoid giving agents unrestricted access to sensitive directories.
- Prefer read-only workflows when testing new tools.
- Keep browser automation isolated from personal accounts when possible.

## Local Command Execution Warning

Some workflows may involve shell execution through WSL or MCP tools. Shell execution can modify files, install packages, access local paths, and run scripts.

Before executing commands:

1. Review the command.
2. Confirm the working directory.
3. Avoid commands that delete, overwrite, or exfiltrate files.
4. Use a test directory when possible.
5. Keep backups of important files.

## Browser Automation Warning

Browser automation can interact with websites, submit forms, take screenshots, and access logged-in sessions.

Recommended precautions:

1. Use a dedicated browser profile.
2. Avoid using personal accounts during tests.
3. Do not store cookies or session files in the repository.
4. Review automation instructions before execution.

## Reporting Security Issues

If you find a security issue, please do not publish exploit details in a public issue. Contact the maintainer privately or use GitHub Security Advisories if enabled.
