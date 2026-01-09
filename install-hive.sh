#!/bin/bash
# Hive Code Installer for Linux
# Run: chmod +x install-hive.sh && ./install-hive.sh
# Fully automated - installs Node.js if needed

clear
echo ""
echo "==================================================="
echo "  Hive Code Installer"
echo "==================================================="
echo ""

INSTALL_PATH="/usr/local/bin/ccode"
SESSIONS_DIR="$HOME/.claude-sessions"
SCRIPT_URL="https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.sh"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing..."
    echo ""

    # Detect package manager and install Node.js
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu - use NodeSource
        echo "Detected Debian/Ubuntu. Installing Node.js via NodeSource..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif command -v dnf &> /dev/null; then
        # Fedora
        echo "Detected Fedora. Installing Node.js..."
        sudo dnf install -y nodejs npm
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        echo "Detected CentOS/RHEL. Installing Node.js via NodeSource..."
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
        sudo yum install -y nodejs
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        echo "Detected Arch Linux. Installing Node.js..."
        sudo pacman -Sy --noconfirm nodejs npm
    elif command -v zypper &> /dev/null; then
        # openSUSE
        echo "Detected openSUSE. Installing Node.js..."
        sudo zypper install -y nodejs npm
    else
        echo "Could not detect package manager."
        echo "Please install Node.js manually from https://nodejs.org/"
        exit 1
    fi

    echo "Node.js installed."
    echo ""
fi

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "Installing Claude CLI..."
    echo "This may take a minute..."
    sudo npm install -g @anthropic-ai/claude-code
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
    echo "  Open a NEW terminal and run:"
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
