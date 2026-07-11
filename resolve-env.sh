#!/usr/bin/env bash
# ============================================================
# resolve-env.sh — Replace all {{PLACEHOLDER}} tokens in
# workflow, config, and campaign files with values from .env
# ============================================================
# Usage:
#   ./resolve-env.sh          # preview changes (dry-run)
#   ./resolve-env.sh --apply  # apply changes in-place
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
APPLY=false

if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

# ── Load .env ────────────────────────────────────────────────
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌  .env file not found at $ENV_FILE"
  echo "    Copy .env.example → .env and fill in your values first."
  exit 1
fi

# Read .env into an associative array (skip comments & blanks)
declare -A ENV_VARS
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip comments and blank lines
  [[ -z "$line" || "$line" == \#* ]] && continue
  # Split on first = only (values may contain =)
  key="${line%%=*}"
  value="${line#*=}"
  # Trim whitespace from key
  key="$(echo "$key" | xargs 2>/dev/null || echo "$key")"
  [[ -z "$key" ]] && continue
  # Remove surrounding quotes from value
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  ENV_VARS["$key"]="$value"
done < "$ENV_FILE"

echo "📦  Loaded ${#ENV_VARS[@]} variables from .env"
echo ""

# ── Count empty values ───────────────────────────────────────
EMPTY_COUNT=0
for key in "${!ENV_VARS[@]}"; do
  if [[ -z "${ENV_VARS[$key]}" ]]; then
    EMPTY_COUNT=$((EMPTY_COUNT + 1))
  fi
done

if [[ $EMPTY_COUNT -gt 0 ]]; then
  echo "⚠️   $EMPTY_COUNT variables are still empty in .env:"
  for key in $(echo "${!ENV_VARS[@]}" | tr ' ' '\n' | sort); do
    if [[ -z "${ENV_VARS[$key]}" ]]; then
      echo "     • $key"
    fi
  done
  echo ""
fi

# ── Target directories ──────────────────────────────────────
TARGET_DIRS=(
  "$SCRIPT_DIR/workflows"
  "$SCRIPT_DIR/config"
  "$SCRIPT_DIR/campaigns"
  "$SCRIPT_DIR/prompts"
  "$SCRIPT_DIR/docs"
)

# ── Find and replace ────────────────────────────────────────
TOTAL_REPLACEMENTS=0
FILES_MODIFIED=0

for dir in "${TARGET_DIRS[@]}"; do
  [[ ! -d "$dir" ]] && continue
  
  while IFS= read -r -d '' file; do
    FILE_CHANGES=0
    
    for key in "${!ENV_VARS[@]}"; do
      value="${ENV_VARS[$key]}"
      [[ -z "$value" ]] && continue
      
      # Escape special chars in value for sed
      escaped_value=$(printf '%s\n' "$value" | sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//')
      
      # Count occurrences of {{KEY}} in this file
      count=$(grep -c "{{${key}}}" "$file" 2>/dev/null || true)
      
      if [[ $count -gt 0 ]]; then
        if $APPLY; then
          sed -i "s|{{${key}}}|${escaped_value}|g" "$file"
        fi
        echo "  ✏️  ${file##*/}:  {{${key}}} → ${value:0:40}$([ ${#value} -gt 40 ] && echo '...')  ($count occurrence(s))"
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + count))
        FILE_CHANGES=$((FILE_CHANGES + 1))
      fi
    done
    
    if [[ $FILE_CHANGES -gt 0 ]]; then
      FILES_MODIFIED=$((FILES_MODIFIED + 1))
    fi
  done < <(find "$dir" -type f \( -name "*.json" -o -name "*.md" \) -print0)
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if $APPLY; then
  echo "✅  Applied $TOTAL_REPLACEMENTS replacements across $FILES_MODIFIED files."
else
  echo "🔍  Found $TOTAL_REPLACEMENTS replacements across $FILES_MODIFIED files."
  echo "    Run with --apply to make changes:  ./resolve-env.sh --apply"
fi

# ── Check for remaining unresolved placeholders ─────────────
echo ""
REMAINING=$(grep -roh '{{[A-Z_]*}}' "$SCRIPT_DIR/workflows" "$SCRIPT_DIR/config" "$SCRIPT_DIR/campaigns" 2>/dev/null | sort -u || true)

if [[ -n "$REMAINING" ]]; then
  echo "⚠️   Unresolved placeholders still in files:"
  echo "$REMAINING" | while read -r placeholder; do
    echo "     • $placeholder"
  done
  echo ""
  echo "    Add these to your .env file or fill them manually."
else
  echo "🎉  All placeholders resolved!"
fi
