#!/bin/bash
# Browser MCP Server - Install Script
# Run this once to set up the environment

set -e

echo "=== Browser MCP Server Setup ==="
echo ""

# Check Python version
python3 --version 2>/dev/null || { echo "ERROR: Python 3 required"; exit 1; }

# Create virtual environment
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate and install
echo "Installing dependencies..."
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Install Playwright browsers
echo ""
echo "Installing Playwright browsers (this takes a minute)..."
playwright install chromium
playwright install-deps chromium 2>/dev/null || echo "Note: System deps may need sudo. Run: sudo playwright install-deps chromium"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To use with Claude Code, add this to your MCP config:"
echo ""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cat << EOF
{
    "mcpServers": {
        "browser": {
            "command": "${SCRIPT_DIR}/.venv/bin/python",
            "args": ["${SCRIPT_DIR}/browser_mcp.py"],
            "env": {
                "BROWSER_HEADLESS": "false"
            }
        }
    }
}
EOF
echo ""
echo "Config locations:"
echo "  Project-level: .mcp.json (in your project root)"
echo "  Global:        ~/.claude/settings.json"
echo ""
