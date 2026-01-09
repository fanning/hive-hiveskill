#!/bin/bash
# Hive Code Bootstrap Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/fanning/hive-hiveskill/master/install.sh | bash

set -e

echo ""
echo "==================================================="
echo "  Hive Code Bootstrap Installer"
echo "==================================================="
echo ""

# Detect platform
case "$(uname -s)" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    *)          echo "Unsupported platform"; exit 1;;
esac

# Set install location
if [ "$PLATFORM" = "macos" ]; then
    INSTALL_PATH="/usr/local/bin/ccode"
    CMD_NAME="ccode"
else
    INSTALL_PATH="/usr/local/bin/cc"
    CMD_NAME="cc"
fi

# Create directories
mkdir -p "$HOME/.claude-sessions/logs"

# Initialize sessions.json if needed
SESSIONS_FILE="$HOME/.claude-sessions/sessions.json"
if [ ! -f "$SESSIONS_FILE" ]; then
    echo '{"version":"1.0","lastUpdated":"","sessions":[]}' > "$SESSIONS_FILE"
fi

# Download the bootstrap script
SCRIPT_URL="https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.sh"

echo "Downloading Hive Code bootstrap script..."
if curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH"; then
    chmod +x "$INSTALL_PATH"
    echo ""
    echo "==================================================="
    echo "  Installation complete!"
    echo "==================================================="
    echo ""
    echo "  Command: $CMD_NAME"
    echo "  Location: $INSTALL_PATH"
    echo ""
    echo "  Quick start:"
    echo "    $CMD_NAME -h              Show help"
    echo "    $CMD_NAME \"Project\"       Start named session"
    echo "    $CMD_NAME -r              Restore a session"
    echo ""
    echo "==================================================="
else
    echo "Failed to download. Try running with sudo:"
    echo "  curl -fsSL $SCRIPT_URL | sudo bash"
    exit 1
fi
