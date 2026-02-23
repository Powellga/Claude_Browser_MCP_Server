# Browser MCP Server

**Give Claude Code a browser.** This MCP server bridges Claude Code (or any MCP client) with a real browser via Playwright, enabling AI agents to navigate websites, interact with pages, fill forms, take screenshots, and more — all from the command line.

## The Problem

Claude Code lives in the terminal. It can write code, run scripts, and manage files — but it can't interact with the web. Need to test a UI? Check a deployment? Scrape dynamic content? You have to switch contexts manually.

## The Solution

This MCP server gives Claude Code a full browser automation toolkit. Claude Code can now:

- **Navigate** to any URL and read page content
- **Click** buttons, links, and interactive elements
- **Type** into forms with realistic keystroke simulation
- **Screenshot** pages or specific elements (returned as base64 PNG)
- **Find** elements by CSS selector, text, XPath, or ARIA role
- **Execute JavaScript** in the page context
- **Manage tabs** — open, close, switch between them
- **Scroll, hover, wait** — full interactive control

## What is MCP?

**Model Context Protocol** is an open standard created by Anthropic that lets AI models connect to external tools and data sources through a unified interface. Think of it like USB-C for AI: a standardized plug that lets any MCP client (Claude Code, Claude Desktop, etc.) talk to any MCP server (a browser automation tool, a database connector, a Slack integration, whatever).

The key pieces:

- **MCP Server** — Exposes "tools" (functions the AI can call), "resources" (data it can read), and "prompts" (templates). That's what this project is: a server that exposes `browser_navigate`, `browser_click`, `browser_screenshot`, etc.
- **MCP Client** — The AI application that discovers and calls those tools. Claude Code and Claude Desktop are both MCP clients.
- **Transport** — How they communicate: `stdio` for local processes (what this server uses) or `streamable HTTP` for remote/networked servers.

The practical upshot: instead of every AI tool building its own proprietary plugin system, MCP gives you one protocol. Write a server once, and it works with any compliant client. This browser server works with Claude Code today and any future MCP-compatible agent.

## Quick Start

### 1. Install

**Linux / macOS:**
```bash
cd Claude_Browser_MCP_Server
chmod +x install.sh
./install.sh
```

**Windows:**
```powershell
cd Claude_Browser_MCP_Server
python -m venv .venv
.venv\Scripts\pip install -r requirements.txt
.venv\Scripts\playwright install chromium
```

This creates a virtual environment, installs dependencies, and downloads Chromium.

### 2. Configure Claude Code

**Option A — CLI (recommended):**
```bash
claude mcp add browser -s user -e BROWSER_HEADLESS=false -- /path/to/.venv/bin/python /path/to/browser_mcp.py
```

On Windows:
```powershell
claude mcp add browser -s user -e BROWSER_HEADLESS=false -- C:\path\to\.venv\Scripts\python.exe C:\path\to\browser_mcp.py
```

**Option B — Manual config:**

Add to your **project-level** `.mcp.json`:

```json
{
    "mcpServers": {
        "browser": {
            "command": "/path/to/.venv/bin/python",
            "args": ["/path/to/browser_mcp.py"],
            "env": {
                "BROWSER_HEADLESS": "false"
            }
        }
    }
}
```

Or add to **global** `~/.claude/settings.json` under the same `mcpServers` key.

### 3. Use It

In Claude Code, just ask it to do browser things:

```
> Go to https://myapp.dev and check if the login page loads correctly
> Navigate to the admin dashboard and take a screenshot
> Fill out the contact form on our website with test data
> Check what our competitor's pricing page looks like
```

Claude Code will automatically use the browser tools when appropriate.

## Available Tools

| Tool | Description |
|------|-------------|
| `browser_navigate` | Go to a URL, returns title and HTTP status |
| `browser_click` | Click elements by selector, text, or XPath |
| `browser_type` | Type into inputs with keystroke simulation |
| `browser_fill` | Instantly fill form fields (no keystrokes) |
| `browser_select` | Select dropdown options by value or label |
| `browser_hover` | Hover to reveal tooltips/menus |
| `browser_scroll` | Scroll page or specific elements |
| `browser_wait` | Wait for elements or fixed delays |
| `browser_screenshot` | Capture page/element as base64 PNG |
| `browser_find` | Find elements by selector, text, or ARIA role |
| `browser_get_text` | Extract text content from page/element |
| `browser_get_html` | Get raw HTML content |
| `browser_evaluate` | Execute arbitrary JavaScript |
| `browser_keyboard` | Press keys and keyboard shortcuts |
| `browser_back` | Navigate back in history |
| `browser_forward` | Navigate forward in history |
| `browser_tabs` | Create, close, list, switch tabs |
| `browser_page_info` | Get URL, title, viewport, element counts |

## Configuration

Environment variables (set in the `env` block of your MCP config):

| Variable | Default | Description |
|----------|---------|-------------|
| `BROWSER_HEADLESS` | `true` | Set `false` to see the browser window |
| `BROWSER_VIEWPORT_WIDTH` | `1280` | Browser viewport width in pixels |
| `BROWSER_VIEWPORT_HEIGHT` | `720` | Browser viewport height in pixels |
| `BROWSER_TIMEOUT` | `30000` | Default timeout in milliseconds |
| `BROWSER_TYPE` | `chromium` | Browser engine: `chromium`, `firefox`, `webkit` |

## Example Workflows

### QA Testing
```
"Navigate to localhost:3000, log in with test credentials,
 go to the dashboard, and screenshot any error states"
```

### Competitive Research
```
"Go to competitor.com/pricing, extract their plan names and prices,
 then check their features page"
```

### Form Automation
```
"Fill out the insurance quote form on our staging site with
 these test values: Name=John Doe, DOB=1990-01-15, ..."
```

### Web Scraping
```
"Navigate to the job board, find all Python developer positions
 posted this week, and extract the company names and salaries"
```

## How Selectors Work

The tools accept flexible selectors:

- **CSS**: `#login-button`, `.nav-link`, `input[name='email']`
- **XPath**: `//button[@type='submit']`
- **Text**: `text=Sign In` or just `Sign In` (auto-detected)
- **Role**: Use `browser_find` with `role='button'`
- **Playwright**: `button >> text=Submit`, `.form >> input`

If a CSS/XPath selector finds nothing, it automatically falls back to text matching.

## Architecture

```
Claude Code (CLI)
    |
    +-- MCP Protocol (stdio)
    |
    v
Browser MCP Server (Python)
    |
    +-- FastMCP (tool registration + validation)
    +-- Pydantic (input validation)
    |
    v
Playwright (async)
    |
    v
Chromium Browser
```

The server maintains a persistent browser instance across tool calls using FastMCP's lifespan management. The browser launches once when the MCP connection starts and closes when it ends.

## Compatibility

- **Python**: 3.10+
- **MCP SDK**: 1.26.0+
- **Playwright**: 1.58.0+
- **Platforms**: Windows, macOS, Linux

## Troubleshooting

**"Playwright browsers not installed"**
```bash
cd Claude_Browser_MCP_Server && source .venv/bin/activate  # Linux/macOS
# or: .venv\Scripts\activate  # Windows
playwright install chromium
sudo playwright install-deps chromium  # Linux system deps
```

**"Connection refused" / Server not starting**
- Check the path in your MCP config points to the correct `.venv/bin/python` (Linux/macOS) or `.venv\Scripts\python.exe` (Windows)
- Ensure the virtual environment was created successfully
- Try running manually: `.venv/bin/python browser_mcp.py`
- Check server status: `claude mcp list`

**Headless mode on Linux server**
```json
"env": {
    "BROWSER_HEADLESS": "true"
}
```

**Timeouts on slow pages**
```json
"env": {
    "BROWSER_TIMEOUT": "60000"
}
```

## License

MIT — do whatever you want with it.
