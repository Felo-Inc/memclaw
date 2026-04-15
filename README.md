<p align="center">
  <img src="https://memclaw.me/logo/memclaw.svg" alt="MemClaw logo" width="80" />
</p>

<h1 align="center">MemClaw</h1>

<p align="center">
  <strong>Persistent project memory for AI coding agents — isolated workspaces, visual dashboard, team collaboration.</strong>
</p>

<p align="center">
  <a href="https://github.com/Felo-Inc/memclaw/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square" alt="MIT License" /></a>
  <a href="https://github.com/Felo-Inc/memclaw/stargazers"><img src="https://img.shields.io/github/stars/Felo-Inc/memclaw?style=flat-square&color=orange" alt="GitHub Stars" /></a>
  <a href="https://github.com/Felo-Inc/memclaw/issues"><img src="https://img.shields.io/github/issues/Felo-Inc/memclaw?style=flat-square" alt="Issues" /></a>
  <a href="https://memclaw.me"><img src="https://img.shields.io/badge/Website-memclaw.me-blueviolet?style=flat-square" alt="Website" /></a>
</p>

<p align="center">
  <a href="https://memclaw.me">Website</a> · <a href="#install">Install</a> · <a href="https://memclaw.me/docs">Documentation</a> · <a href="https://felo.ai/settings/api-keys">Get API Key</a> · <a href="#why-memclaw">Why MemClaw?</a>
</p>

---

## The Problem

AI coding agents forget everything between sessions. When you juggle multiple projects, things get worse — Client A's context bleeds into Client B's conversation, and you waste time re-explaining project details every time you start a new chat.

**MemClaw fixes this.** It gives your AI agent a persistent, project-isolated memory system with a web dashboard so you can actually see and manage what your agent remembers.

<p align="center">
  <img src="https://memclaw.me/resources/claw/memclaw.png" alt="MemClaw workspace dashboard" width="700" />
</p>

---

## Why MemClaw?

Unlike general-purpose AI memory tools, MemClaw is designed specifically for **project-level isolation**:

| Feature | MemClaw | General memory tools |
|---------|---------|---------------------|
| **Project isolation** | Each project gets its own workspace — zero context bleed | Memory is shared across all conversations |
| **Visual dashboard** | Web UI to review, edit, and manage agent memory | Memory is invisible — you can't see what the agent remembers |
| **Team collaboration** | Invite teammates to shared project workspaces | Single-user only |
| **Structured memory** | Tasks, artifacts, and a living project README | Flat key-value or vector store |
| **Free to use** | Core features are free | Often requires paid plans |

---

## What It Does

- **Workspaces** — one project = one workspace, identified by name. Client A's context never touches Client B's.
- **Artifacts** — save research reports, documents, URLs, and files to the workspace.
- **README memory** — agent maintains a structured project README: background, user preferences, current progress.
- **Query** — retrieve workspace contents by browsing or semantic search.
- **Cross-session** — load any workspace and pick up exactly where things left off.
- **Web dashboard** — open [memclaw.me](https://memclaw.me) to view and manage all your project memories.

---

## Use Cases

### Sales & Consulting
Track 6 clients simultaneously. Each client gets their own workspace with pricing history, requirements, and communication notes. Switch between clients without context contamination.

### Multi-Project Development
Three repos, three workspaces. Your AI agent remembers each project's architecture, constraints, and TODO list independently. No more re-explaining your tech stack.

### Research & Knowledge Work
Accumulate papers, insights, and notes into project-specific knowledge bases. Your AI agent builds structured knowledge over time instead of losing it in chat history.

---

## Install

Get your API key from [felo.ai](https://felo.ai/settings/api-keys), then set it:

```bash
export FELO_API_KEY="your-api-key-here" # Linux/macOS
$env:FELO_API_KEY="your-api-key-here"   # Windows (PowerShell)
```

The key can also be persisted in `~/.memclaw/env`.

### Claude Code

```bash
# Add the marketplace
/plugin marketplace add Felo-Inc/memclaw

# Install the skill
/plugin install memclaw@memclaw
```

### OpenClaw

```bash
bash <(curl -s https://raw.githubusercontent.com/Felo-Inc/memclaw/main/scripts/openclaw-install.sh)
```

### Manual Installation

```bash
git clone https://github.com/Felo-Inc/memclaw.git

# Copy the skill folder to your AI agent's skills directory
# Claude Code:  ~/.claude/skills/
# Gemini CLI:   ~/.gemini/skills/
# Codex:        ~/.codex/skills/
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
| **Workspace** | One project = one persistent knowledge base |
| **Registry** | `~/.memclaw/workspaces.json`, maps project names to workspace IDs |
| **README** | Agent's memory of the project — background, preferences, progress |
| **Artifacts** | Key outputs saved to the workspace (reports, docs, URLs, files) |

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Whether it's a bug fix, feature request, or documentation improvement — all contributions help make MemClaw better for everyone.

---

## Community

- **Website**: [memclaw.me](https://memclaw.me)
- **Documentation**: [memclaw.me/docs](https://memclaw.me/docs)
- **Bug Reports**: [GitHub Issues](https://github.com/Felo-Inc/memclaw/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Felo-Inc/memclaw/discussions)

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with care by the <a href="https://felo.ai">Felo</a> team · <a href="https://memclaw.me">memclaw.me</a>
</p>
