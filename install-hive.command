#!/bin/bash
# Hive Code Installer for macOS
# Double-click this file to install - fully automated

clear
echo ""
echo "==================================================="
echo "  Hive Code Installer"
echo "==================================================="
echo ""

INSTALL_PATH="/usr/local/bin/ccode"
SESSIONS_DIR="$HOME/.claude-sessions"
SCRIPT_URL="https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.sh"
NODE_PKG="/tmp/node-installer.pkg"
NODE_URL="https://nodejs.org/dist/v20.11.0/node-v20.11.0.pkg"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Downloading installer..."
    echo ""
    curl -fsSL "$NODE_URL" -o "$NODE_PKG"

    if [ ! -f "$NODE_PKG" ]; then
        echo "Failed to download Node.js installer."
        echo "Press any key to close..."
        read -n 1
        exit 1
    fi

    echo "Installing Node.js (you may be prompted for your password)..."
    echo ""
    sudo installer -pkg "$NODE_PKG" -target /

    # Clean up
    rm -f "$NODE_PKG"

    # Refresh PATH
    export PATH="/usr/local/bin:$PATH"

    echo "Node.js installed."
    echo ""
fi

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "Installing Claude CLI..."
    echo "This may take a minute..."
    npm install -g @anthropic-ai/claude-code
    echo "Claude CLI installed."
    echo ""
fi

echo "Creating directories..."
mkdir -p "$SESSIONS_DIR/logs"

echo "Downloading Hive Code bootstrap..."

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
    echo "  Open a NEW Terminal window and run:"
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
echo "Press any key to close..."
read -n 1
