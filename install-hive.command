#!/bin/bash
# Hive Code Installer for macOS
# Double-click this file to install

clear
echo ""
echo "==================================================="
echo "  Hive Code Installer"
echo "==================================================="
echo ""

INSTALL_PATH="/usr/local/bin/ccode"
SESSIONS_DIR="$HOME/.claude-sessions"
SCRIPT_URL="https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.sh"

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "Claude CLI not found. Checking for npm..."
    if ! command -v npm &> /dev/null; then
        echo ""
        echo "==================================================="
        echo "  ERROR: Node.js is required"
        echo "==================================================="
        echo ""
        echo "  Please install Node.js first:"
        echo "  https://nodejs.org/"
        echo ""
        echo "  Or with Homebrew: brew install node"
        echo ""
        echo "  Then run this installer again."
        echo "==================================================="
        echo ""
        echo "Press any key to close..."
        read -n 1
        exit 1
    fi
    echo "Installing Claude CLI via npm..."
    echo "This may take a minute..."
    npm install -g @anthropic-ai/claude-code
    if [ $? -ne 0 ]; then
        echo ""
        echo "Failed to install Claude CLI. Please run manually:"
        echo "  npm install -g @anthropic-ai/claude-code"
        echo ""
        echo "Press any key to close..."
        read -n 1
        exit 1
    fi
    echo "Claude CLI installed successfully."
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
    echo "  Open Terminal and run:"
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
