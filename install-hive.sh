#!/bin/bash
# Hive Code Installer for Linux
# Run: chmod +x install-hive.sh && ./install-hive.sh

clear
echo ""
echo "==================================================="
echo "  Hive Code Installer"
echo "==================================================="
echo ""

INSTALL_PATH="/usr/local/bin/ccode"
SESSIONS_DIR="$HOME/.claude-sessions"
SCRIPT_URL="https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.sh"

echo "Creating directories..."
mkdir -p "$SESSIONS_DIR/logs"

echo "Downloading Hive Code..."

# Try without sudo first
if curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH" 2>/dev/null; then
    chmod +x "$INSTALL_PATH"
else
    # Need sudo
    echo "Need administrator access to install to /usr/local/bin"
    sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
fi

if [ -f "$INSTALL_PATH" ]; then
    echo ""
    echo "==================================================="
    echo "  Installation complete!"
    echo "==================================================="
    echo ""
    echo "  Location: $INSTALL_PATH"
    echo ""
    echo "  Open a new terminal and run:"
    echo "    ccode -h          Show help"
    echo "    ccode \"Project\"   Start a session"
    echo "    ccode -r          Restore a session"
    echo ""
    echo "==================================================="
else
    echo ""
    echo "Installation failed. Please try again."
fi

echo ""
