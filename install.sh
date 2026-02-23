#!/bin/bash
# Browser MCP Server - Install Script
# Run this once to set up the environment
# Supports Linux, macOS, and Windows (Git Bash/WSL)

set -e

echo "=== Browser MCP Server Setup ==="
echo ""

# Detect OS and set Python command
if command -v python3 &>/dev/null; then
    PYTHON=python3
elif command -v python &>/dev/null; then
    PYTHON=python
else
    echo "ERROR: Python 3 required"
    exit 1
fi

echo "Using: $($PYTHON --version)"

# Create virtual environment
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    $PYTHON -m venv .venv
fi

# Activate based on OS
if [ -f ".venv/Scripts/activate" ]; then
    # Windows (Git Bash / MSYS2)
    source .venv/Scripts/activate
    VENV_PYTHON=".venv/Scripts/python.exe"
else
    # Linux / macOS
    source .venv/bin/activate
    VENV_PYTHON=".venv/bin/python"
fi

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install Playwright browsers
echo ""
echo "Installing Playwright browsers (this takes a minute)..."
playwright install chromium
playwright install-deps chromium 2>/dev/null || echo "Note: System deps may need sudo on Linux. Run: sudo playwright install-deps chromium"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To use with Claude Code, run:"
echo ""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "  claude mcp add browser -- \"${SCRIPT_DIR}/${VENV_PYTHON}\" \"${SCRIPT_DIR}/browser_mcp.py\""
echo ""
echo "Or add this to your MCP config:"
echo ""
cat << EOF
{
    "mcpServers": {
        "browser": {
            "command": "${SCRIPT_DIR}/${VENV_PYTHON}",
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
echo "  CLI:           claude mcp add browser -s user -e BROWSER_HEADLESS=false -- ..."
echo ""
