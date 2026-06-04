#!/bin/bash
set -euo pipefail

# v1.2 Session Checkpoint Manager
# Usage: ./scripts/v1.2-checkpoint.sh <task-id> <status> "<summary>"
# Statuses: pending | in_progress | completed | blocked

TASK_ID="${1:?Usage: v1.2-checkpoint.sh <task-id> <status> '<summary>'}"
STATUS="${2:?Status required}"
SUMMARY="${3:-No summary}"
STATE_FILE=".planning/v1.2-session-state.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ ! -f "$STATE_FILE" ]; then
  echo "ERROR: State file not found at $STATE_FILE"
  exit 1
fi

# Determine which phase the task belongs to
PHASE=$(echo "$TASK_ID" | grep -oE '^[A-Z]+-[0-9]' | head -1)
PHASE_NUM=$(echo "$PHASE" | grep -oE '[0-9]+')

if [ -z "$PHASE_NUM" ]; then
  # Non-phase task, just add checkpoint
  jq --arg ts "$TS" --arg tid "$TASK_ID" --arg st "$STATUS" --arg sm "$SUMMARY" \
    '.checkpoints += [{"timestamp": $ts, "task": $tid, "status": $st, "summary": $sm}] | .currentSession.lastCheckpoint = $ts' \
    "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
else
  PHASE_KEY="phase${PHASE_NUM}"
  
  # Update task status in the correct phase
  jq --arg ts "$TS" --arg tid "$TASK_ID" --arg st "$STATUS" --arg sm "$SUMMARY" --arg pk "$PHASE_KEY" \
    '
    if .phases[$pk].tasks[$tid] then
      .phases[$pk].tasks[$tid].status = $st
    else
      .
    end
    | .currentSession.lastCheckpoint = $ts
    | .currentSession.currentTask = $tid
    | .checkpoints += [{"timestamp": $ts, "task": $tid, "status": $st, "summary": $sm}]
    | .lastUpdated = $ts
    ' \
    "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
fi

# Add to session history
SESSION_ID=$(jq -r '.currentSession.id' "$STATE_FILE")
jq --arg sid "$SESSION_ID" --arg ts "$TS" --arg tid "$TASK_ID" --arg st "$STATUS" --arg sm "$SUMMARY" \
  '
  .sessionHistory[-1].tasksCompleted += [$tid]
  | .sessionHistory[-1].lastActivity = $ts
  ' \
  "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"

echo "✓ Checkpoint: $TASK_ID → $STATUS at $TS"
echo "  Summary: $SUMMARY"

# Check if all tasks in current phase are done
REMAINING=$(jq -r --arg pk "phase${PHASE_NUM}" '.phases[$pk].tasks | to_entries[] | select(.value.status != "completed") | .key' "$STATE_FILE" 2>/dev/null | wc -l)
if [ "$REMAINING" -eq 0 ] && [ -n "$PHASE_NUM" ]; then
  echo "🎉 Phase ${PHASE_NUM} COMPLETE! All tasks done."
  # Unlock next phase
  NEXT=$((PHASE_NUM + 1))
  if [ "$NEXT" -le 4 ]; then
    jq --arg pk "phase${NEXT}" '.phases[$pk].status = "in_progress" | .phases[$pk].blockedBy = []' \
      "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
    echo "  → Phase ${NEXT} unlocked."
  fi
fi
