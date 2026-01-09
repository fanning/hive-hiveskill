#!/bin/bash
# cc.sh - Hive Code Bootstrap with Crash Recovery
# Version 1.7.0 - Standalone edition
# Works on Linux and macOS

set -e

SESSIONS_DIR="$HOME/.claude-sessions"
SESSIONS_FILE="$SESSIONS_DIR/sessions.json"
LOGS_DIR="$SESSIONS_DIR/logs"
CC_VERSION="1.7.0"

# Detect platform
case "$(uname -s)" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    *)          PLATFORM="unknown";;
esac

# Ensure directories exist
mkdir -p "$SESSIONS_DIR" "$LOGS_DIR"

# Initialize sessions.json if needed
if [ ! -f "$SESSIONS_FILE" ]; then
    echo '{"version":"1.0","lastUpdated":"","sessions":[]}' > "$SESSIONS_FILE"
fi

# Show help
show_help() {
    cat << EOF

===================================================
  Hive Code Bootstrap v$CC_VERSION
===================================================

USAGE:
  ccode                      Start new session (auto-named)
  ccode "Name"               Start session with custom name
  ccode -c, --continue       Continue most recent session
  ccode -r, --restore        Interactive session restore
  ccode -l, --list           List all sessions
  ccode --setup-token        Set up long-lived token (1 year)
  ccode --check-token        Check token expiry status
  ccode -h, --help           Show this help

SESSION NAMING:
  Format: "Project : Goal : Task"
  Example: ccode "MyApp : Build : Feature X"

LONG-LIVED TOKENS:
  Run 'ccode --setup-token' once per year for persistent agents.
  Tokens last 1 year vs 24 hours for regular OAuth.
  Run 'ccode --check-token' to see days until expiry.

FILES:
  Sessions: $SESSIONS_FILE

NOTE:
  On macOS, use 'ccode' instead of 'cc' (cc is the C compiler).

===================================================
EOF
}

# Check token expiry
check_token() {
    local creds_file="$HOME/.claude/.credentials.json"
    if [ ! -f "$creds_file" ]; then
        echo "No credentials file found."
        return 1
    fi

    if command -v jq &> /dev/null; then
        local expires_at=$(jq -r '.claudeAiOauth.expiresAt' "$creds_file")
        local now_ms=$(($(date +%s) * 1000))
        local days_left=$(( (expires_at - now_ms) / 1000 / 86400 ))
        local expiry_date=$(date -d "@$((expires_at / 1000))" 2>/dev/null || date -r "$((expires_at / 1000))" 2>/dev/null || echo "unknown")

        echo ""
        echo "Hive Token Status:"
        echo "  Expires: $expiry_date"
        echo "  Days left: $days_left"
        echo ""

        if [ "$days_left" -le 30 ]; then
            echo -e "\033[33mWARNING: Token expires in $days_left days! Run 'ccode --setup-token' to renew.\033[0m"
        else
            echo -e "\033[32mToken OK - $days_left days remaining\033[0m"
        fi
    else
        echo "Install jq for token status: brew install jq (Mac) or apt install jq (Linux)"
    fi
}

# List sessions
list_sessions() {
    echo ""
    echo "=== All Sessions ==="
    echo ""
    if command -v jq &> /dev/null; then
        jq -r '.sessions | sort_by(.started) | reverse[] | "[\(.status | ascii_upcase)] \(.name)\n  ID: \(.id)\n  Started: \(.started)\n"' "$SESSIONS_FILE" 2>/dev/null || echo "No sessions found."
    else
        cat "$SESSIONS_FILE"
    fi
}

# Interactive restore
do_restore() {
    echo ""
    echo "Recent sessions:"
    echo ""
    if command -v jq &> /dev/null; then
        jq -r '.sessions | sort_by(.started) | reverse | to_entries | .[:10][] | "[\(.key + 1)] [\(.value.status | ascii_upcase)] \(.value.name)\n    \(.value.id)"' "$SESSIONS_FILE"
    else
        echo "Install jq for interactive restore"
        return 1
    fi
    echo ""
    read -p "Enter session number (or 'q' to quit): " choice

    if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
        return
    fi

    local resume_id=$(jq -r ".sessions | sort_by(.started) | reverse | .[$((choice - 1))].id" "$SESSIONS_FILE")
    if [ -n "$resume_id" ] && [ "$resume_id" != "null" ]; then
        echo "Resuming session: $resume_id"
        claude --dangerously-skip-permissions --resume "$resume_id"
    else
        echo "Invalid selection."
    fi
}

# Handle arguments
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    --setup-token)
        echo ""
        echo "Setting up long-lived authentication token..."
        echo "This token lasts 1 year and is required for persistent agents."
        echo ""
        claude setup-token
        exit 0
        ;;
    --check-token)
        check_token
        exit 0
        ;;
    -c|--continue)
        echo "Continuing most recent session..."
        claude --dangerously-skip-permissions --continue
        exit 0
        ;;
    -r|--restore)
        if [ -n "$2" ]; then
            echo "Resuming session: $2"
            claude --dangerously-skip-permissions --resume "$2"
        else
            do_restore
        fi
        exit 0
        ;;
    -l|--list)
        list_sessions
        exit 0
        ;;
esac

# Main session flow

# Generate session ID
SESSION_ID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")

# Set session name
if [ -z "$1" ]; then
    SESSION_NAME="$PLATFORM : General : $(date '+%Y-%m-%d %H:%M')"
else
    SESSION_NAME="$1"
fi

# Set terminal title
echo -ne "\033]0;$SESSION_NAME\007"

# Display session info
echo ""
echo "==================================================="
echo "  Hive Code Session Starting"
echo "==================================================="
echo "  Session ID: $SESSION_ID"
echo "  Name: $SESSION_NAME"
echo "  Platform: $PLATFORM"
echo "==================================================="
echo ""

# Record session start
if command -v jq &> /dev/null; then
    temp_file=$(mktemp)
    jq --arg id "$SESSION_ID" --arg name "$SESSION_NAME" \
       '.sessions += [{id: $id, name: $name, started: (now | todate), status: "running"}]' \
       "$SESSIONS_FILE" > "$temp_file" && mv "$temp_file" "$SESSIONS_FILE"
fi

echo "Starting Hive Code..."
echo ""

# Run Claude
claude --dangerously-skip-permissions --session-id "$SESSION_ID"

# Record session end
if command -v jq &> /dev/null; then
    temp_file=$(mktemp)
    jq --arg id "$SESSION_ID" \
       '(.sessions[] | select(.id == $id)).status = "stopped" | (.sessions[] | select(.id == $id)).ended = (now | todate)' \
       "$SESSIONS_FILE" > "$temp_file" && mv "$temp_file" "$SESSIONS_FILE"
fi

echo ""
echo "Session ended."
