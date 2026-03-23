#!/bin/bash
# Check if taste-skill is installed for /design command
# Runs on SessionStart — prints recommendation if missing

TASTE_FOUND=0

# Check plugin cache (installed via `claude plugin install`)
if find ~/.claude/plugins/cache -path "*/taste-skill*" -name "SKILL.md" -print -quit 2>/dev/null | grep -q .; then
  TASTE_FOUND=1
fi

# Check manual skill install
if [ -f ~/.claude/skills/taste-skill/SKILL.md ]; then
  TASTE_FOUND=1
fi

if [ "$TASTE_FOUND" -eq 0 ]; then
  echo "[jobc-power-commands] /design 커맨드의 전체 기능을 사용하려면 taste-skill 설치를 권장합니다:"
  echo "  claude plugin install --git https://github.com/Leonxlnx/taste-skill"
  echo "  또는 수동: git clone https://github.com/Leonxlnx/taste-skill && cp -R taste-skill/skills/* ~/.claude/skills/"
fi
