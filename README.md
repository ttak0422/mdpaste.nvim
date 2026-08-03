# mdpaste.nvim

Paste rich clipboard content as markdown. Copy a link in your browser, paste
`[title](url)` in Neovim — like GUI editors do.

Reads the HTML flavor of the system clipboard and converts it to markdown
(links, images, emphasis, code, headings, lists). Falls back to a plain
`"+` paste when the clipboard has no HTML.

## Requirements

- Neovim >= 0.10
- macOS: `osascript` (built-in) / Wayland: `wl-paste` / X11: `xclip`

## Install

```lua
-- lazy.nvim
{ "ttak0422/mdpaste.nvim" }
```

## Usage

`:MdPaste`, or map it (e.g. in `after/ftplugin/markdown.lua`):

```lua
vim.keymap.set({ "n", "i" }, "<C-v>", "<Plug>(mdpaste)", { buffer = true })
```

## API

```lua
require("mdpaste").paste()          -- put converted clipboard at cursor
require("mdpaste").clipboard_html() -- string? raw HTML flavor
require("mdpaste").html_to_md(html) -- string  convert an HTML fragment
```
