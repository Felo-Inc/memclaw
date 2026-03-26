# MemClaw

<p align="center">
  <strong>The AI agent's external brain — persistent project workspaces across sessions.</strong>
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
</p>

**MemClaw** is a skill for AI coding agents. It gives agents persistent project workspaces — each workspace stores tasks, artifacts, and a living README so any session (or collaborator) can load it and immediately have full context.

---

## What It Does

- **Workspaces** — one project = one workspace, identified by name
- **Task sync** — agent creates a task before starting work, marks it done when finished; all tracked silently
- **Artifacts** — save research reports, documents, URLs, and files to the workspace
- **README memory** — agent maintains a structured project README: background, user preferences, current progress
- **Query** — retrieve workspace contents by browsing or semantic search
- **Cross-session** — load any workspace and pick up exactly where things left off

---

## Install

Get your API key from [felo.ai](https://felo.ai) (Settings → API Keys), then set it:

```bash
export FELO_API_KEY="your-api-key-here"    # Linux/macOS
$env:FELO_API_KEY="your-api-key-here"      # Windows (PowerShell)
```

The key can also be persisted in `~/.memclaw/env`.

### Claude Code

```bash
# Add the marketplace
/plugin marketplace add Felo-Inc/memclaw

# Install the skill
/plugin install memclaw@memclaw
```

### ClawHub

```bash
clawhub install memclaw
```

### OpenClaw

```bash
bash <(curl -s https://raw.githubusercontent.com/Felo-Inc/memclaw/main/scripts/openclaw-install.sh)
```

### Manual

```bash
git clone https://github.com/Felo-Inc/memclaw.git
# Copy the skill folder to your AI agent's skills directory
# Claude Code: ~/.claude/skills/
# Gemini CLI:  ~/.gemini/skills/
# Codex:       ~/.codex/skills/
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

---

## How It Works

| Concept | Description |
|---------|-------------|
| Workspace | One project = one persistent knowledge base |
| Registry | `~/.memclaw/workspaces.json`, maps project names to workspace IDs |
| README | Agent's memory of the project — background, preferences, progress |
| Artifacts | Key outputs saved to the workspace (reports, docs, URLs, files) |
| Tasks | Auto-tracked for every substantive action the agent takes |

---

## License

MIT — see [LICENSE](./LICENSE) for details.

---

<p align="center">Made with ❤️ by the <a href="https://felo.ai">Felo</a> team</p>
