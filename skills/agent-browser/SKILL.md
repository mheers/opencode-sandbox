---
name: agent-browser
description: Use agent-browser to start and interact with a real web browser for testing, scraping, or verifying web-based features
---

## What I do

I help you use agent-browser to launch a headless Chromium instance and interact with real web pages. agent-browser is a browser automation CLI that uses a snapshot-and-ref workflow optimized for AI agents — you navigate, snapshot the accessibility tree, then interact with elements by ref.

## When to use me

Use this skill when you need to interact with a real web browser — for example to verify a web UI, scrape content, test a local dev server, or automate a multi-step browser workflow.

## Steps

1. Run `agent-browser --help` to review the available commands.
2. Run `agent-browser open <url>` to navigate to a URL (e.g. `http://localhost:3000` or any public site). This launches the browser automatically if not already running.
3. Run `agent-browser snapshot -i` to get the accessibility tree with interactive elements and their refs (`@e1`, `@e2`, etc.).
4. Use refs from the snapshot to interact with elements:
   - `agent-browser click @e1` — click an element
   - `agent-browser fill @e2 "text"` — clear and fill an input field
   - `agent-browser get text @e1` — extract text from an element
   - `agent-browser get attr @e1 href` — get an attribute value
   - `agent-browser hover @e3` — hover over an element
   - `agent-browser select @e4 "value"` — select a dropdown option
5. After the page changes, run `agent-browser snapshot -i` again to get updated refs.
6. Use additional commands as needed:
   - `agent-browser screenshot [file]` — take a screenshot
   - `agent-browser eval "<js>"` — evaluate JavaScript
   - `agent-browser wait "<selector>"` — wait for an element to appear
   - `agent-browser wait --load networkidle` — wait for network to be idle
   - `agent-browser get title` / `agent-browser get url` — inspect the current page
   - `agent-browser tab` — list open tabs
   - `agent-browser tab new <url>` — open a new tab
   - `agent-browser back` / `agent-browser forward` / `agent-browser reload` — navigation
7. When finished, run `agent-browser close` to shut down the browser.

## Core workflow

The recommended workflow for AI agents is:

1. `agent-browser open <url>` — navigate
2. `agent-browser snapshot -i` — get interactive elements with refs
3. `agent-browser click @e1` / `agent-browser fill @e2 "text"` — interact using refs
4. Re-snapshot after page changes

## Tips

- Refs (`@e1`, `@e2`, etc.) are deterministic identifiers from the most recent snapshot. Always re-snapshot after navigating or triggering page changes.
- Use `agent-browser snapshot -i -c` for a compact view of interactive elements only.
- Use `agent-browser snapshot -i --json` for machine-readable output.
- CSS selectors also work: `agent-browser click "#submit"`.
- Use `agent-browser is visible "<selector>"` to check element visibility (exit code 0 = visible).
- Combine with showboat to capture browser interactions in a demo document.
