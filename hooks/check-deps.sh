#!/bin/bash
# jobc-power-commands: SessionStart dependency checker
# Checks for recommended plugins and prints install instructions for missing ones

MISSING=()

# --- Helper: check if a plugin exists in cache or manual install ---
check_plugin() {
  local cache_pattern="$1"
  local manual_path="$2"

  # Check plugin cache
  if find ~/.claude/plugins/cache -path "*${cache_pattern}*" -name "*.md" -print -quit 2>/dev/null | grep -q .; then
    return 0
  fi

  # Check manual install path (if provided)
  if [ -n "$manual_path" ] && [ -e "$manual_path" ]; then
    return 0
  fi

  return 1
}

# --- 1. taste-skill (for /design) ---
if ! check_plugin "taste-skill" "$HOME/.claude/skills/taste-skill/SKILL.md"; then
  MISSING+=("taste-skill")
fi

# --- 2. claude-plugins-official (for pr-review-toolkit, feature-dev) ---
if ! check_plugin "claude-plugins-official" ""; then
  if ! find ~/.claude/plugins/cache -path "*pr-review*" -print -quit 2>/dev/null | grep -q .; then
    MISSING+=("claude-plugins-official")
  fi
fi

# --- 3. pm-skills (for write-prd, write-stories, etc.) ---
if ! check_plugin "pm-skills" ""; then
  MISSING+=("pm-skills")
fi

# --- Report ---
if [ ${#MISSING[@]} -eq 0 ]; then
  exit 0
fi

echo ""
echo "[jobc-power-commands] ${#MISSING[@]} recommended plugin(s) not installed:"
echo ""

for plugin in "${MISSING[@]}"; do
  case "$plugin" in
    taste-skill)
      echo "  taste-skill (detailed preset rules for /design)"
      echo "    claude plugin install --git https://github.com/Leonxlnx/taste-skill"
      ;;
    claude-plugins-official)
      echo "  claude-plugins-official (4-agent review for /check, feature-dev)"
      echo "    claude plugin install --git https://github.com/anthropics/claude-plugins-official"
      ;;
    pm-skills)
      echo "  pm-skills (/write-prd, /write-stories, /pre-mortem, /test-scenarios)"
      echo "    claude plugin install --git https://github.com/phuryn/pm-skills"
      ;;
  esac
  echo ""
done

echo "  Works standalone, but these plugins unlock full capabilities."
echo ""
