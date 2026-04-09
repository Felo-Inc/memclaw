# MemClaw

**The AI agent's external brain — persistent project workspaces across sessions.**

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

[Website](https://memclaw.me) · [Install Guide](#install) · [Documentation](https://memclaw.me/docs) · [Get API Key](https://felo.ai/settings/api-keys)

**MemClaw** is a skill for AI coding agents. It gives agents persistent project workspaces — each workspace stores tasks, artifacts, and a living README so any session (or collaborator) can load it and immediately have full context.

---

## What It Does

- **Workspaces** — one project = one workspace, identified by name
- **Artifacts** — save research reports, documents, URLs, and files to the workspace
- **README memory** — agent maintains a structured project README: background, user preferences, current progress
- **Query** — retrieve workspace contents by browsing or semantic search
- **Cross-session** — load any workspace and pick up exactly where things left off

---

## Install

Get your API key from [felo.ai](https://felo.ai/settings/api-keys), then set it:

```shell
export FELO_API_KEY="your-api-key-here" # Linux/macOS
$env:FELO_API_KEY="your-api-key-here" # Windows (PowerShell)
```

The key can also be persisted in `~/.memclaw/env`.


### Claude Code

```shell
# Add the marketplace
/plugin marketplace add Felo-Inc/memclaw

# Install the skill
/plugin install memclaw@memclaw
```

### OpenClaw

```shell
bash <(curl -s https://raw.githubusercontent.com/Felo-Inc/memclaw/main/scripts/openclaw-install.sh)
```

### Manual

```shell
git clone https://github.com/Felo-Inc/memclaw.git
# Copy the skill folder to your AI agent's skills directory
# Claude Code: ~/.claude/skills/
# Gemini CLI: ~/.gemini/skills/
# Codex: ~/.codex/skills/
cp -r memclaw/memclaw ~/.claude/skills/
```

---

## Usage

Just talk to the agent naturally:

```
Create a workspace called Client Acme
Load the Acme workspace
What's in my workspace?
Save that report to the workspace
```

The agent handles task tracking, artifact saving, and README updates automatically — no extra commands needed.

Learn more at [memclaw.me](https://memclaw.me).

---

## How It Works

| Concept | Description |
|---------|-------------|
| Workspace | One project = one persistent knowledge base |
| Registry | `~/.memclaw/workspaces.json`, maps project names to workspace IDs |
| README | Agent's memory of the project — background, preferences, progress |
| Artifacts | Key outputs saved to the workspace (reports, docs, URLs, files) |

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

Made with care by the [Felo](https://felo.ai) team · [memclaw.me](https://memclaw.me)
