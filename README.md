# Browser & File MCP Server

**Give Claude Code browser and file superpowers.** This MCP server bridges Claude Code (or any MCP client) with a real browser via Playwright **and** adds the ability to read Excel, Word, PowerPoint, CSV, and image files — all from the command line.

## The Problem

Claude Code lives in the terminal. It can write code, run scripts, and manage files — but it can't interact with the web. Need to test a UI? Check a deployment? Scrape dynamic content? You have to switch contexts manually.

## The Solution

This MCP server gives Claude Code a full browser automation toolkit **and** file reading capabilities. Claude Code can now:

- **Navigate** to any URL and read page content
- **Click** buttons, links, and interactive elements
- **Type** into forms with realistic keystroke simulation
- **Screenshot** pages or specific elements (returned as base64 PNG)
- **Find** elements by CSS selector, text, XPath, or ARIA role
- **Execute JavaScript** in the page context
- **Manage tabs** — open, close, switch between them
- **Scroll, hover, wait** — full interactive control
- **Read Excel** workbooks — sheets, headers, data as markdown tables
- **Read Word** documents — text, headings, tables
- **Read PowerPoint** presentations — slide text, tables, speaker notes
- **Read CSV** files — with configurable delimiters and encoding
- **Read images** — JPG, PNG, GIF, BMP, WebP, TIFF returned as base64 for Claude's vision
- **Inspect files** — metadata, size, type, modification date

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

## Available Tools (25)

### Browser Tools (18)

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

### File Tools (7)

| Tool | Description |
|------|-------------|
| `file_info` | File metadata: size, type, modified date, readability |
| `file_list_sheets` | List all sheet names and dimensions in an Excel workbook |
| `file_read_excel` | Read Excel sheets as markdown tables (configurable rows, start position) |
| `file_read_csv` | Read CSV files as markdown tables (configurable delimiter, encoding) |
| `file_read_word` | Extract text, headings, and tables from .docx files |
| `file_read_powerpoint` | Extract slide text, tables, and speaker notes from .pptx files |
| `file_read_image` | Read images as base64 PNG for Claude's vision (auto-resizes large images) |

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

### Read a Spreadsheet
```
"Read the Excel file at C:\Reports\Q1_sales.xlsx and summarize the data"
"List all sheets in the workbook and show me the first 50 rows of the Summary tab"
```

### Analyze an Image
```
"Look at the screenshot at C:\Users\gregg\Desktop\error.png and tell me what the error is"
"Read the architecture diagram at C:\docs\system_diagram.jpg and describe the components"
```

### Process Documents
```
"Read the Word doc at C:\proposals\draft.docx and check for any inconsistencies"
"Extract all the slide content from the PowerPoint at C:\presentations\quarterly.pptx"
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
- **openpyxl**: 3.1.0+ (Excel)
- **python-docx**: 1.1.0+ (Word)
- **python-pptx**: 1.0.0+ (PowerPoint)
- **Pillow**: 10.0.0+ (Images)
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

## Companion Project: Claude Code IDE

This MCP server is designed to work with the **[Claude Code IDE](https://github.com/Powellga/Claude-Code-IDE)** — a full web-based IDE that wraps Claude Code's CLI with project management, session recording, and a multi-tab interface.

When used together:

- **File upload with auto-ingestion** — Click the upload button in the IDE, select a file (Excel, Word, PowerPoint, image, CSV), and it drops into the project's working directory. The IDE automatically prompts Claude to read it using this server's file tools. No copy-pasting, no file paths to type.
- **Zero configuration** — Claude Code discovers this MCP server automatically via `~/.claude/settings.json`. Start a session in the IDE and all 25 tools are available immediately.
- **Session persistence** — The IDE records every conversation, cleans the raw terminal output through a virtual terminal emulator, and lets you resume sessions natively. The MCP tools are available across resumed sessions without reconnecting.
- **Working directory awareness** — Each IDE project has a configured working directory. Files uploaded through the IDE land in that directory, and file tool paths resolve relative to where Claude Code is actually running.

The IDE handles the UI, session management, and PTY process lifecycle. This server handles browser automation and file processing. They communicate through Claude Code's MCP protocol — the IDE never talks to this server directly.

## License

MIT — do whatever you want with it.
