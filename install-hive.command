#!/bin/bash
# Hive Code Installer for macOS
# Double-click this file to install - fully automated
# Installs: Node.js, Claude CLI, Hive Agent
# Then connects to agent.hiveskill.com

clear
echo ""
echo "==================================================="
echo "  Hive Code Installer"
echo "==================================================="
echo ""

AGENT_DIR="$HOME/.hive-agent"
PACKAGE_DIR="$AGENT_DIR/package"
CONFIG_FILE="$AGENT_DIR/config.json"
NODE_PKG="/tmp/node-installer.pkg"
NODE_URL="https://nodejs.org/dist/v20.11.0/node-v20.11.0.pkg"
REPO_ZIP="/tmp/ai-web-interface.zip"
REPO_URL="https://github.com/fanning/ai-web-interface/archive/refs/heads/main.zip"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "[1/5] Installing Node.js..."
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
else
    echo "[1/5] Node.js already installed."
fi

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "[2/5] Installing Claude CLI..."
    echo "This may take a minute..."
    npm install -g @anthropic-ai/claude-code
    echo "Claude CLI installed."
    echo ""
else
    echo "[2/5] Claude CLI already installed."
fi

# Create agent directory
echo "[3/5] Setting up Hive Agent..."
mkdir -p "$AGENT_DIR"

# Download the agent package
echo "Downloading Hive Agent package..."
curl -fsSL "$REPO_URL" -o "$REPO_ZIP"

if [ ! -f "$REPO_ZIP" ]; then
    echo "Failed to download Hive Agent package."
    echo "Press any key to close..."
    read -n 1
    exit 1
fi

# Extract the zip
echo "Extracting..."
rm -rf "$PACKAGE_DIR"
unzip -q "$REPO_ZIP" -d "$AGENT_DIR"

# Rename extracted folder
if [ -d "$AGENT_DIR/ai-web-interface-main" ]; then
    mv "$AGENT_DIR/ai-web-interface-main" "$PACKAGE_DIR"
fi

# Clean up zip
rm -f "$REPO_ZIP"

# Install dependencies
echo "[4/5] Installing dependencies..."
cd "$PACKAGE_DIR"
npm install --production

# Initialize agent (generate password)
echo "[5/5] Initializing Hive Agent..."
CONFIG_JSON=$(node scripts/init-agent.js --json 2>/dev/null | tail -1)

# Extract password from config
PASSWORD=$(echo "$CONFIG_JSON" | grep -o '"password":"[^"]*"' | cut -d'"' -f4)

# Start agent in background
echo ""
echo "Starting Hive Agent..."
nohup node server/agent.js > "$AGENT_DIR/agent.log" 2>&1 &
AGENT_PID=$!

# Save PID for later
echo "$AGENT_PID" > "$AGENT_DIR/agent.pid"

# Wait a moment for agent to connect
sleep 3

echo ""
echo "==================================================="
echo "  Installation complete!"
echo "==================================================="
echo ""
echo "  Your Hive Code agent is now running and connected."
echo ""
echo "  Opening your dashboard in the browser..."
echo ""
echo "==================================================="
echo "  YOUR PASSWORD (save this!)"
echo "==================================================="
echo ""
echo "  Password: $PASSWORD"
echo ""
echo "  You will need this password to access your"
echo "  sessions at https://agent.hiveskill.com"
echo ""
echo "==================================================="
echo ""

# Open browser to hub
open "https://agent.hiveskill.com/?password=$PASSWORD"

echo "Press any key to close..."
read -n 1
