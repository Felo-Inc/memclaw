# Contributing to MemClaw

Thanks for your interest in contributing to MemClaw! We welcome all contributions — bug fixes, features, documentation improvements, and more.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/memclaw.git`
3. Create a branch: `git checkout -b my-feature`
4. Make your changes
5. Commit: `git commit -m "Add my feature"`
6. Push: `git push origin my-feature`
7. Open a Pull Request

## Development Setup

```bash
git clone https://github.com/Felo-Inc/memclaw.git
cd memclaw

# Get an API key from https://felo.ai/settings/api-keys
export FELO_API_KEY="your-api-key-here"

# Copy skill to your agent's directory for testing
cp -r memclaw ~/.claude/skills/
```

## What Can I Contribute?

- **Bug fixes** — found something broken? Fix it and open a PR.
- **New features** — have an idea? Open an issue first to discuss.
- **Documentation** — typos, unclear instructions, missing examples.
- **Use cases** — share how you use MemClaw in your workflow.
- **Integrations** — add support for new AI coding agents.

## Code Style

- Keep it simple and readable
- Add comments for non-obvious logic
- Follow existing patterns in the codebase

## Reporting Issues

When reporting bugs, please include:

- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your environment (OS, AI agent, version)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
