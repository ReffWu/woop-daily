#!/usr/bin/env bash
# woop-daily: log-session.sh
# Appends a completed WOOP session to ~/.woop-daily/log.md and sessions.jsonl
#
# Usage:
#   log-session.sh <mode> <wish> <outcome> <obstacle> <plan>
#
# All arguments should be quoted strings.

set -euo pipefail

MODE="${1:-today}"
WISH="${2:-}"
OUTCOME="${3:-}"
OBSTACLE="${4:-}"
PLAN="${5:-}"

LOG_DIR="$HOME/.woop-daily"
LOG_MD="$LOG_DIR/log.md"
LOG_JSONL="$LOG_DIR/sessions.jsonl"

mkdir -p "$LOG_DIR"

# Timestamp
TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")
TS_HUMAN=$(date +"%Y-%m-%d %H:%M" 2>/dev/null || echo "$TS_ISO")

# Mode label
case "$MODE" in
  today)  MODE_LABEL="今日" ;;
  week)   MODE_LABEL="本周" ;;
  habit)  MODE_LABEL="习惯" ;;
  review) MODE_LABEL="回顾" ;;
  *)      MODE_LABEL="$MODE" ;;
esac

# --- Append to sessions.jsonl (machine-readable) ---
# Escape double quotes in content
escape_json() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n' | sed 's/\\n$//'
}

JSON_LINE="{\"ts\":\"$TS_ISO\",\"mode\":\"$MODE\",\"wish\":\"$(escape_json "$WISH")\",\"outcome\":\"$(escape_json "$OUTCOME")\",\"obstacle\":\"$(escape_json "$OBSTACLE")\",\"plan\":\"$(escape_json "$PLAN")\"}"
echo "$JSON_LINE" >> "$LOG_JSONL"

# --- Append to log.md (human-readable) ---
{
  echo ""
  echo "---"
  echo ""
  echo "## $TS_HUMAN · $MODE_LABEL"
  echo ""
  echo "**🎯 愿望：** $WISH"
  echo ""
  echo "**✨ 最好结果：** $OUTCOME"
  echo ""
  echo "**🧱 内在障碍：** $OBSTACLE"
  echo ""
  echo "**📋 如果-那么计划：** $PLAN"
  echo ""
} >> "$LOG_MD"

# Output total count
TOTAL=$(wc -l < "$LOG_JSONL" | tr -d ' ')
echo "LOGGED: session #$TOTAL saved to $LOG_MD"
