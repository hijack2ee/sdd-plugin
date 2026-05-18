#!/usr/bin/env bash
#
# build-codex.sh — Generate Codex CLI prompts from skills/<name>/SKILL.md
#
# skills/ is the single source of truth. .codex/prompts/ is derived.
#
# Usage:
#   scripts/build-codex.sh           Rebuild .codex/prompts/ from skills/
#   scripts/build-codex.sh --check   CI mode — exit 1 if .codex/ is out of sync
#
set -euo pipefail

CHECK_MODE=false
if [[ "${1:-}" == "--check" ]]; then
  CHECK_MODE=true
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
CODEX_DIR="$REPO_ROOT/.codex/prompts"

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "✗ skills/ not found at $SKILLS_DIR" >&2
  exit 1
fi

mkdir -p "$CODEX_DIR"

EXIT_CODE=0
WROTE=0
SKIPPED=0

# Strip YAML frontmatter (---...---) at the top of a SKILL.md.
# Writes the body (everything after the closing ---) to stdout.
strip_frontmatter() {
  awk '
    BEGIN { in_fm = 0 }
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; next }
    in_fm { next }
    { print }
  ' "$1"
}

# Build/check each skill
for skill_md in "$SKILLS_DIR"/*/SKILL.md; do
  [[ -f "$skill_md" ]] || continue
  skill_name="$(basename "$(dirname "$skill_md")")"
  target="$CODEX_DIR/$skill_name.md"
  tmp="$(mktemp)"

  strip_frontmatter "$skill_md" > "$tmp"

  if $CHECK_MODE; then
    if [[ ! -f "$target" ]] || ! diff -q "$target" "$tmp" >/dev/null 2>&1; then
      echo "✗ drift: $target out of sync with $skill_md"
      EXIT_CODE=1
    fi
    rm -f "$tmp"
  else
    if [[ -f "$target" ]] && diff -q "$target" "$tmp" >/dev/null 2>&1; then
      SKIPPED=$((SKIPPED + 1))
      rm -f "$tmp"
    else
      mv "$tmp" "$target"
      echo "✓ wrote .codex/prompts/$skill_name.md"
      WROTE=$((WROTE + 1))
    fi
  fi
done

# Orphan cleanup — remove .codex prompts whose source skill was deleted
if ! $CHECK_MODE; then
  for codex_md in "$CODEX_DIR"/*.md; do
    [[ -e "$codex_md" ]] || continue
    name="$(basename "$codex_md" .md)"
    if [[ ! -d "$SKILLS_DIR/$name" ]]; then
      rm -f "$codex_md"
      echo "✗ removed orphan: .codex/prompts/$name.md"
    fi
  done
fi

if $CHECK_MODE; then
  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✓ .codex/prompts/ in sync with skills/"
  else
    echo ""
    echo "Fix: scripts/build-codex.sh"
    exit 1
  fi
else
  echo ""
  echo "done. wrote: $WROTE, unchanged: $SKIPPED"
fi
