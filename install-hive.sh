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
        echo "  Or with your package manager:"
        echo "    Ubuntu/Debian: sudo apt install nodejs npm"
        echo "    Fedora: sudo dnf install nodejs npm"
        echo "    Arch: sudo pacman -S nodejs npm"
        echo ""
        echo "  Then run this installer again."
        echo "==================================================="
        echo ""
        exit 1
    fi
    echo "Installing Claude CLI via npm..."
    echo "This may take a minute..."
    npm install -g @anthropic-ai/claude-code
    if [ $? -ne 0 ]; then
        echo ""
        echo "Failed to install Claude CLI. Try with sudo:"
        echo "  sudo npm install -g @anthropic-ai/claude-code"
        echo ""
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
