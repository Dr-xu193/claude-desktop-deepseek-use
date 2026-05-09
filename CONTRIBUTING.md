# Contributing

Thank you for your interest in this project.

This repository is currently an early public validation branch for multi-model coding-agent workflows. Contributions are welcome, especially in areas that improve reproducibility, safety, documentation, and real-world developer workflows.

## Areas Where Contributions Are Welcome

- Improving installation instructions
- Testing MCP server compatibility
- Adding Codex-compatible workflow examples
- Adding Claude Desktop workflow examples
- Adding DeepSeek workflow examples
- Adding browser automation examples
- Improving WSL setup instructions
- Improving security notes
- Reporting setup issues on Windows, WSL, and Linux
- Adding reproducible coding-agent evaluation tasks

## Pull Request Guidelines

1. Keep examples reproducible.
2. Do not include API keys, tokens, cookies, session files, or private configuration.
3. Prefer placeholder-based configuration files.
4. Explain which model, tool, or MCP server your example uses.
5. Include screenshots or logs only after removing private data.
6. Avoid destructive command examples.
7. Add safety warnings when examples involve shell execution, file writes, or browser automation.

## Commit Message Style

Recommended examples:

```text
docs: improve WSL setup guide
docs: add Codex workflow example
chore: add security checklist
examples: add GitHub issue triage workflow
examples: add browser automation workflow
```

## Development Notes

This repository may involve tools that can access local files, execute shell commands, or automate browsers. Always review commands before execution and use the minimum required permissions.
