#!/usr/bin/env bash
# Install memclaw into OpenClaw's workspace skills directory
# Usage: ./scripts/openclaw-install.sh [--dry-run]

set -euo pipefail

GLOBAL_SKILLS_DIR="${HOME}/.openclaw/skills"
WORKSPACE_SKILLS_DIR="${HOME}/.openclaw/workspace/skills"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Find all SKILL.md files and install each skill
installed=0
skipped=0

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  global_target="${GLOBAL_SKILLS_DIR}/${skill_name}"
  workspace_target="${WORKSPACE_SKILLS_DIR}/${skill_name}"

  if [[ -e "$workspace_target" ]]; then
    skipped=$((skipped + 1))
    continue
  fi

  if $DRY_RUN; then
    echo "  [dry-run] would install: $skill_name"
  else
    mkdir -p "$GLOBAL_SKILLS_DIR" "$WORKSPACE_SKILLS_DIR"
    cp -r "$skill_dir" "$global_target"
    ln -sf "$global_target" "$workspace_target"
    echo "  ✅ installed: $skill_name"
  fi
  installed=$((installed + 1))
done < <(find "$REPO_DIR" -name "SKILL.md" -not -path "*/.git/*")

if $DRY_RUN; then
  echo ""
  echo "Dry run complete. Would install $installed skill(s). ($skipped already exist)"
else
  echo ""
  echo "Done. Installed $installed skill(s). ($skipped already existed)"
  if [[ $installed -gt 0 ]]; then
    echo ""
    echo "Restarting OpenClaw gateway..."
    openclaw gateway restart
    echo ""
    echo "MemClaw is ready! Try these to get started:"
    echo "   - Create a new project"
    echo "   - Track or record something for later"
    echo "   - Open your workspace"
  fi
fi
