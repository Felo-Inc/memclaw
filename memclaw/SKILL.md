---
name: memclaw
description: "Use when users need to manage projects backed by Felo LiveDoc — creating, opening, switching projects, saving artifacts, querying history, or managing tasks. Triggers on project-related intent combined with project/client/niche names, or on 401 UNAUTHORIZED errors from Felo API."
---

# MemClaw

The Agent's external brain for projects. Once active, the Agent continuously syncs tasks, artifacts, and knowledge to the corresponding LiveDoc, so anyone (including future sessions or colleagues) can open the project and immediately get full context.

## Core Concepts

| Concept | Description |
|---------|-------------|
| Project | One project = one LiveDoc |
| Active Project | Session-level state; all operations auto-sync here |
| README | The Agent's memory of the project; Agent maintains proactively |
| Artifacts | Key outputs; Agent asks before saving |
| Tasks | Tracking records for substantive work; Agent maintains silently |
| Registry | `~/.memclaw/workspaces.json`, maps project names to LiveDoc IDs |

**Registry format:**
```json
{
  "workspaces": {
    "horror-niche": "abc123",
    "client-zhang": "def456"
  }
}
```

## Script Shorthand

In all commands below, `$SCRIPT` refers to:

```
node ./scripts/run.mjs
```

When unsure about a command's options, run `$SCRIPT <command> --help` or just `$SCRIPT --help` to see the full usage.

## Commands Reference

| Command | Description |
|---------|-------------|
| `create` | Create a new LiveDoc (`--name` required) |
| `list` | List all LiveDocs |
| `update <short_id>` | Update a LiveDoc |
| `delete <short_id>` | Delete a LiveDoc |
| `resources <short_id>` | List resources in a LiveDoc |
| `resource <short_id> <resource_id>` | Get a single resource |
| `add-doc <short_id>` | Create a text document resource (`--content` required) |
| `add-urls <short_id>` | Add URL resources (`--urls` required, comma-separated, max 10) |
| `upload <short_id>` | Upload a file resource (`--file` required, `--convert` optional) |
| `remove-resource <short_id> <resource_id>` | Delete a resource |
| `update-resource <short_id> <resource_id>` | Update resource title, snippet, or thumbnail |
| `update-resource-content <short_id> <resource_id>` | Update Markdown content of an `ai_doc` resource (`--content` required) |
| `content <short_id> <resource_id>` | Get text content of a resource |
| `download <short_id> <resource_id>` | Download source file to disk |
| `retrieve <short_id>` | Semantic retrieval (`--query` required; auto-routes if no `--resource-ids`) |
| `route <short_id>` | Route relevant resource IDs by query (`--query` required) |
| `ppt-retrieve <short_id>` | PPT page deep retrieval (`--resource-id`, `--page-number`, `--query` required) |
| `get-readme <short_id>` | Get README content |
| `update-readme <short_id>` | Create or replace README (`--content` required) |
| `append-readme <short_id>` | Append content to README (`--content` required) |
| `delete-readme <short_id>` | Delete README |
| `tasks <short_id>` | List tasks (filter by `--status`, `--labels`) |
| `create-task <short_id>` | Create a task (`--title` required; `--status` default 0, `--sort` default 0) |
| `update-task <short_id> <task_id>` | Partially update a task |
| `delete-task <short_id> <task_id>` | Delete a task |
| `task-records <short_id> <task_id>` | List task records (comments + change history) |
| `add-task-comment <short_id> <task_id>` | Add a comment to a task (`--content` required) |

## When NOT to Use

- Simple chitchat or clarifying questions
- One-off generation unrelated to any project
- User has not installed the Felo LiveDoc NPM package

---

## Workflows

### 0. First-Time Installation

User pastes GitHub install link → execute installation → after completion, automatically enter **Login flow (0a)**.

### 0a. Login / Re-authorization

**Trigger conditions (either one):**
- First-time installation, Key not yet configured
- Any API call returns `{"status":401,"code":"UNAUTHORIZED","message":"Invalid API Key"}`

**Flow:**

1. Send login link:
   > "Please click the link to log in / register a Felo account: https://felo.ai/settings/api-keys
   > Once done, paste the Key back to me and I'll complete the setup automatically."
2. User pastes Key → write to config:
   ```bash
   export FELO_API_KEY="user's Key"
   ```
   Or persist to `~/.memclaw/env` (platform-dependent).
3. Verify: `$SCRIPT list`
   - Pass + first install → show usage introduction (see "First-Time Usage Introduction" below)
   - Pass + re-authorization → "✅ Authorization updated." → retry the failed command
   - Fail → "Invalid Key, please paste again."

**First-Time Usage Introduction** (show only on first install; skip on re-authorization):

> "🎉 Setup complete! You can now manage your projects:
>
> 📁 **New project** — Create a standalone project for a new task
> Example: 'Create a project for horror niche'
>
> 📂 **Open project** — Open an existing project, restore context
> Example: 'Open horror niche'
>
> 📋 **View all projects** — List all projects or view project contents
> Example: 'What projects do I have?' / 'What's in the horror niche?'
>
> 💾 **Save artifacts** — Important outputs will prompt you to save
>
> Projects record everything we do. You can view them anytime on the web: https://memclaw.felo.ai"

### 1. Open Project

1. Read `~/.memclaw/workspaces.json`, fuzzy-match project name. If not found locally, try `$SCRIPT list --keyword`.
2. **Found:** Set as active project → `$SCRIPT get-readme SHORT_ID` → present README as project briefing → append link `https://felo.ai/livedoc/SHORT_ID?from=claw`. If README is empty or missing, fall back to `$SCRIPT resources SHORT_ID` to show the resource list.
3. **Not found:** "No project found for '[X]'. Want me to create one?"

### 2. Create Project

```bash
$SCRIPT create --name "Project Name" --description "workspace"
```

Extract `short_id` → initialize README (see "README Structure Template" below) → update registry → set as active project → reply:

> "✅ Project '[X]' created. 📎 https://felo.ai/livedoc/SHORT_ID?from=claw"

### 3. Task Sync (Mandatory Checklist)

**Every time the user gives a request that requires the Agent to invoke tools to produce new content, the following checklist must be executed strictly in order. No step may be skipped:**

```
□ Step 1: Confirm project — Does the user's request belong to the active project?
           - If the user mentions a different project/account/niche/client → switch or create the correct project first
           - If it matches the active project → continue
□ Step 2: create-task — Create a task under the correct project (status=1)
□ Step 3: Execute — Invoke tools to complete the user's request
□ Step 4: update-task — Mark the task as done (status=2)
□ Step 5: Check README — Did this operation bring any new understanding? If yes, update (see Section 5)
```

**When to run this checklist (task required):**
- "Search for 10 horror niche YouTube videos" → requires search + adding
- "Collect client info on Mr. Zhang" → requires search + generation
- "Write a competitive analysis report" → requires generation
- "Search for recent gold price trends" → requires search

**When NOT to run (project management operations):**
- "Open Mr. Zhang's project" → project operation
- "What projects do I have?" → viewing all projects
- "Refresh" / "Create a new project" → project management
- "Save that report" → saving artifacts
- "Update the README" / "Rename the project" → project maintenance
- Chitchat, clarifying questions

---

**Step 1 Details — Confirm project:**

If the user's message mentions a different project/account/niche/client name, it means a project switch is needed.

Examples:
- Active project is "horror niche", user says "I also have an account for pet niche, search 10 videos for me" → **must switch to pet niche project first** (if it doesn't exist, ask whether to create it)
- Active project is "horror niche", user says "keep searching 10 more horror videos" → matches, continue

**Step 2 Details — create-task:**

```bash
$SCRIPT create-task SHORT_ID --title "Task description" --status 1 --sort 0 [--operated-by "Agent Name"]
```
Save the returned `task_id` in working memory.

`--title` should be a one-line summary of what the user wants done, e.g.:
- User says "Search for 10 horror niche YouTube videos" → `--title "Search 10 horror niche YouTube videos"`
- User says "Collect info on Mr. Zhang" → `--title "Collect client info on Mr. Zhang"`

`--operated-by` rules:
- **Only pass it if the Agent has been given a name** in this session (e.g. an OpenClaw agent with an assigned name)
- **Omit it if no explicit name** (e.g. a plain Claude Code session)

**Step 4 Details — update-task:**

```bash
$SCRIPT update-task SHORT_ID TASK_ID --status 2 [--operated-by "Agent Name"]
```
(`--operated-by` rule same as above — pass it when the Agent has a name.)

**On opening a project:** Pull pending and in-progress tasks:
```bash
$SCRIPT tasks SHORT_ID --status 0
$SCRIPT tasks SHORT_ID --status 1
```

Execute the entire checklist silently — do not narrate the task sync to the user. If you forgot to create a task before starting, create it retroactively and mark it DONE immediately. Never skip it.

### 4. Save Artifacts (Ask First)

After producing significant output, ask the user: "Want me to save this to the project?"

Significant artifacts = research reports, competitive analyses, meeting summaries, generated documents, key data exports. Intermediate drafts do not need to be saved.

| Type | Command |
|------|---------|
| Document | `$SCRIPT add-doc SHORT_ID --title "Title" --content "content"` |
| URL | `$SCRIPT add-urls SHORT_ID --urls "URL"` |
| File | `$SCRIPT upload SHORT_ID --file ./path` |

After saving, reply:
> "💾 Saved '[Title]' 📎 https://felo.ai/livedoc/SHORT_ID?from=claw"

### 5. README Maintenance

The README is the Agent's memory of the project — not a work log. Agent maintains proactively, no need to ask the user.

**README Structure Template:**
```markdown
# [Project Name]

## What This Project Is
[Project background, objectives, stakeholders]

## User Preferences & Work Patterns
[How the user likes to work, what dimensions they care about, specific requirements]

## Current Progress
[Where things stand now — updated each session]
Last updated: YYYY-MM-DD
```

**When to update README — core question: Did this operation bring any new understanding?**

**Update if ANY of the following conditions are met:**
1. User states a niche/direction/goal/style/type → record in `## What This Project Is`
   - e.g. "I'm doing the horror niche" → update immediately, record "horror niche"
   - e.g. "This project is mainly B2B SaaS" → update immediately
2. User expresses a preference/habit/requirement → record in `## User Preferences & Work Patterns`
   - e.g. "10 results each time is enough" → record collection quantity preference
   - e.g. "I only want Chinese content" → record language preference
   - e.g. "Focus on high view count ones" → record filtering criteria
3. Project has meaningful progress or direction change → update `## Current Progress`

**Do NOT update:**
- Same-pattern repeated operations (e.g. after collecting info on Mr. Zhang, collecting info on Mr. Li using the same pattern — no update needed)
- The mere fact of executing an action (generating a document is not worth recording by itself)

**Update method:** Read → merge in memory into the correct section → write back in full. Never blindly append to the end.

1. `$SCRIPT get-readme SHORT_ID` to read current content
2. Locate the target section in memory and insert:
   - Project background → `## What This Project Is`
   - User preferences → `## User Preferences & Work Patterns`
   - Progress changes → replace `## Current Progress` section content
3. Update `Last updated: YYYY-MM-DD` to today's date
4. `$SCRIPT update-readme SHORT_ID --content "..."` to write back

**Initialization** (README is empty or missing): Skip step 1, write the full skeleton directly with `update-readme`.

After updating, inform the user:
> "📝 Project memory updated. 📎 https://felo.ai/livedoc/SHORT_ID?from=claw"

### 6. Query Project

Prefer `resources` + `content` (direct read, free) over `retrieve` (LLM-based semantic search, costs money).

```bash
$SCRIPT resources SHORT_ID
$SCRIPT content SHORT_ID RESOURCE_ID
$SCRIPT retrieve SHORT_ID --query "question"   # fallback
```

Synthesize returned content into a direct answer. Do not dump raw results.

### 7. Refresh Project

When the user says "refresh", or when the project may have been updated externally (by a colleague or another session), re-fetch:

```bash
$SCRIPT get-readme SHORT_ID
$SCRIPT resources SHORT_ID
$SCRIPT tasks SHORT_ID --status 0
$SCRIPT tasks SHORT_ID --status 1
```

Update the in-memory snapshot. Tell the user: "Project refreshed." If anything changed, briefly describe the differences (new resources, README updates, new tasks).

### 8. View All Projects

`$SCRIPT list` — list all projects. To view contents of a specific project, use `$SCRIPT resources SHORT_ID`, grouped by type, artifacts newest first.

---

## Session State

```
ACTIVE_PROJECT = { name: "horror-niche", short_id: "abc123" }
```

- Set when user opens or creates a project; clear when user says "close project"
- If no active project and user tries to save/log/query/task: "No project open. Which project?"

## Error Handling

| Error | Action |
|-------|--------|
| Key missing / 401 UNAUTHORIZED | Trigger Login flow (0a) |
| LiveDoc ID stale | Offer to re-link or create new |
| Registry missing | Auto-create with `{"workspaces": {}}` |
| Ambiguous fuzzy match | List all matches, ask user to pick |

## Integration with Other Felo Skills

The active project's `short_id` can be passed directly to other Felo skills that accept a `livedoc_short_id` parameter:

| Skill | How to use the project `short_id` |
|-------|-----------------------------------|
| `felo-slides` | Pass as `livedoc_short_id` when creating a PPT — the generated presentation is saved into the current project automatically |
| `felo-superAgent` | Pass as the canvas LiveDoc ID — SuperAgent conversations run on top of the current project's knowledge base |
| `felo-livedoc` | The `short_id` is the LiveDoc ID — all `felo-livedoc` operations apply directly to the current project |

When the user asks to generate a PPT, run a SuperAgent conversation, or perform advanced LiveDoc operations while a project is active, pass `ACTIVE_PROJECT.short_id` to the relevant skill instead of creating a new LiveDoc.

---

## Integration with Other Felo Skills

The active project's `short_id` is a LiveDoc ID that can be shared with other [Felo Skills](https://github.com/Felo-Inc/felo-skills). Some skills accept a `livedoc_short_id` parameter — when a project is active, pass `ACTIVE_PROJECT.short_id` directly so those skills operate within the same project context.

---

## Important Rules

- Write all content in the user's language — Chinese if they speak Chinese, English if English
- Always use `short_id` for all LiveDoc operations
- Execute commands immediately — don't describe, do
- Task sync and README updates are the Agent's responsibility — proactive, not reactive
- Append project link after every write operation
