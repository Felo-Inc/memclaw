---
name: memclaw
description: "Use when users need to manage projects backed by Felo LiveDoc — creating, opening, switching projects, saving artifacts, querying history, or managing tasks. Also triggers when calling any Felo Doc API operation: LiveDoc CRUD, resource management (add-doc, add-urls, upload, content, download), README operations, task management (create/update/delete tasks, task records, comments), or any other Felo LiveDoc API endpoint. Triggers on project-related intent combined with project/client/niche names."
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
| `get-readme <short_id>` | Get README (returns `summary` + `content`) |
| `update-readme <short_id>` | Create or replace README (`--content` or `--summary` required, at least one) |
| `append-readme <short_id>` | Append content to README (`--content` required) |
| `delete-readme <short_id>` | Delete README |
| `tasks <short_id>` | List tasks (filter by `--status`, `--labels`) |
| `create-task <short_id>` | Create a task (`--title` required; `--status` default 0, `--sort` default 0) |
| `update-task <short_id> <task_id>` | Partially update a task |
| `delete-task <short_id> <task_id>` | Delete a task |
| `task-records <short_id> <task_id>` | List task records (comments + change history) |
| `add-task-comment <short_id> <task_id>` | Add a comment to a task (`--content` required) |

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
2. **Found:** Set as active project (record `is_shared` from the LiveDoc object) → `$SCRIPT get-readme SHORT_ID` → present README as project briefing → append link `https://felo.ai/livedoc/SHORT_ID?from=claw`. If README is empty or missing, fall back to `$SCRIPT resources SHORT_ID` to show the resource list. If `is_shared` is true, add a note: "(read-only — shared project)".
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
□ Step 2: create-task — Skip if ACTIVE_PROJECT.is_shared is true; otherwise create a task (status=1)
□ Step 3: Execute — Invoke tools to complete the user's request
□ Step 4: update-task — Skip if ACTIVE_PROJECT.is_shared is true; otherwise mark the task as done (status=2)
□ Step 5: Check README — Skip if ACTIVE_PROJECT.is_shared is true; otherwise update if new understanding (see Section 5)
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

If `ACTIVE_PROJECT.is_shared` is true, skip this section entirely — do not ask and do not attempt to save.

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

If `ACTIVE_PROJECT.is_shared` is true, skip this section entirely — do not attempt to read or write the README.

The README is the Agent's memory of the project — not a work log. Agent maintains proactively, no need to ask the user.

The README has two parts:
- `summary`: A one-line project description (max 2000 chars). Set it when creating or first understanding the project. Keep it concise — it's the project's elevator pitch.
- `content`: The full README body (Markdown).

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
4. `$SCRIPT update-readme SHORT_ID --summary "one-line description" --content "..."` to write back

**Initialization** (README is empty or missing): Skip step 1, write the full skeleton directly with `update-readme`, including a `--summary`.

After updating, inform the user:
> "📝 Project memory updated. 📎 https://felo.ai/livedoc/SHORT_ID?from=claw"

### 6. Query Project

Use `resources` + `content` to read project knowledge directly.
`content` caches the resource to `~/.memclaw/cache/{livedocid}/{resource_id}_{ts}.md` and returns the local file path.
Revalidates against `modified_at` on each call — no manual cache management needed.

```bash
$SCRIPT resources SHORT_ID
$SCRIPT content SHORT_ID RESOURCE_ID   # returns local cache path
```

Read the returned path to get the full content. Synthesize into a direct answer. Do not dump raw results.

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
ACTIVE_PROJECT = { name: "horror-niche", short_id: "abc123", is_shared: false }
```

- Set when user opens or creates a project; clear when user says "close project"
- If no active project and user tries to save/log/query/task: "No project open. Which project?"
- `is_shared` is read from the LiveDoc object returned by `list` or `create`. When `true`, the project is **read-only**: skip all write operations (create-task, update-task, add-doc, add-urls, upload, update-readme, append-readme). Query and retrieval still work normally. If the user tries to write, reply: "This project is shared (read-only) — I can read it but cannot make changes."

## Error Handling

| Error | Action |
|-------|--------|
| Key missing / 401 UNAUTHORIZED | Trigger Login flow (0a) |
| LiveDoc ID stale | Offer to re-link or create new |
| Registry missing | Auto-create with `{"workspaces": {}}` |
| Ambiguous fuzzy match | List all matches, ask user to pick |

## Integration with Other Felo APIs

The active project's `short_id` is a LiveDoc ID — it is **identical** to `livedoc_short_id` used across all Felo APIs. No conversion needed.

Full API reference: **https://openapi.felo.ai/docs/**

**Universal rule:** Whenever calling any Felo API that accepts a `livedoc_short_id` parameter, always pass `ACTIVE_PROJECT.short_id`. This scopes the result to the current project — content generated (e.g. a PPT) will be automatically added as a resource in the project's LiveDoc and can be retrieved with `$SCRIPT resources SHORT_ID`.

When the user asks for a capability not covered by `$SCRIPT`, call the relevant Felo API directly using `curl` or the Bash tool with `FELO_API_KEY` from the environment. All endpoints use `Authorization: Bearer $FELO_API_KEY`. After getting a result, save significant output back to the project using `$SCRIPT add-urls` or `$SCRIPT add-doc`.

### Available Felo APIs

#### PPT Task API
Generate presentation decks from a prompt (async — create then poll).

| Endpoint | Method | Path | Key params |
|----------|--------|------|------------|
| List themes | GET | `/v2/ppt-themes` | `lang`, `type`, `keyword` |
| Create PPT task | POST | `/v2/ppts` | `query`*, `livedoc_short_id`, `resource_ids`, `ppt_config.ai_theme_id` |
| Query task status | GET | `/v2/tasks/{task_id}/status` | — |
| Query task result | GET | `/v2/tasks/{task_id}/historical` | — |

Poll `/historical` every 10s. Terminal statuses: `COMPLETED`/`SUCCESS` (success), `FAILED`/`ERROR`/`EXPIRED`/`CANCELED` (failure). On success use `ppt_url` (fallback `live_doc_url`).

#### SuperAgent API
AI conversation with web search, scoped to a LiveDoc context.

| Endpoint | Method | Path | Key params |
|----------|--------|------|------------|
| Create conversation | POST | `/v2/conversations` | `query`*, `live_doc_short_id`, `selected_resource_ids` |
| Consume SSE stream | GET | `/v2/conversations/stream/{stream_key}` | `offset` |
| Follow-up | POST | `/v2/conversations/{thread_short_id}/follow_up` | `query`* |
| Get conversation | GET | `/v2/conversations/{thread_short_id}` | — |

#### Chat API
Single-turn web-search-augmented Q&A.

| Endpoint | Method | Path | Key params |
|----------|--------|------|------------|
| Chat | POST | `/v2/chat` | `query`* (1–2000 chars) |

Returns `answer`, `resources` (cited sources).

#### Web Fetch API
Extract content from any URL.

| Endpoint | Method | Path | Key params |
|----------|--------|------|------------|
| Extract page | POST | `/v2/web/extract` | `url`*, `output_format` (html/text/markdown), `crawl_mode` (fast/fine), `with_readability` |

#### YouTube Subtitling API
Fetch subtitles/transcripts from YouTube videos.

| Endpoint | Method | Path | Key params |
|----------|--------|------|------------|
| Get subtitles | GET | `/v2/youtube/subtitling` | `video_code`*, `language`, `with_time` |

Returns `title`, `contents[]`.

#### X (Twitter) Search API
Search and retrieve X/Twitter content.

| Endpoint | Method | Path | Key params |
|----------|--------|------|------------|
| Get user info | POST | `/v2/x/user/info` | `usernames`* |
| Search users | POST | `/v2/x/user/search` | `query`*, `cursor` |
| Get user tweets | POST | `/v2/x/user/tweets` | `x_user_id` or `username`*, `limit`, `cursor` |
| Search tweets | POST | `/v2/x/tweet/search` | `query`*, `query_type`, `since_time`, `until_time`, `limit` |
| Get tweet replies | POST | `/v2/x/tweet/replies` | `tweet_ids`*, `cursor` |

`*` = required

---

## Important Rules

- Write all content in the user's language — Chinese if they speak Chinese, English if English
- Always use `short_id` for all LiveDoc operations
- Execute commands immediately — don't describe, do
- Task sync and README updates are the Agent's responsibility — proactive, not reactive
- Append project link after every write operation
