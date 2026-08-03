local M = {}

local entities = {
  amp = "&",
  lt = "<",
  gt = ">",
  quot = '"',
  apos = "'",
  nbsp = " ",
}

local function decode_entities(s)
  s = s:gsub("&#(%d+);", function(n)
    return vim.fn.nr2char(tonumber(n))
  end)
  s = s:gsub("&(%a+);", entities)
  return s
end

local function attr(attrs, name)
  return attrs:match(name .. '%s*=%s*"([^"]*)"') or attrs:match(name .. "%s*=%s*'([^']*)'")
end

--- Convert an HTML fragment to markdown.
--- ponytail: gsub chain, not a real parser. Covers links/emphasis/lists/headings
--- from typical browser copies; swap in pandoc or an htmlparser if it falls short.
---@param html string
---@return string
function M.html_to_md(html)
  local s = html
  s = s:gsub("<!%-%-.-%-%->", "")
  s = s:gsub("<[sS][tT][yY][lL][eE].->.-</[sS][tT][yY][lL][eE]>", "")
  s = s:gsub("<[sS][cC][rR][iI][pP][tT].->.-</[sS][cC][rR][iI][pP][tT]>", "")
  -- HTML source whitespace is insignificant
  s = s:gsub("%s+", " ")

  -- inline formatting first, so it survives inside link text
  s = s:gsub("<[bB]%f[%A][^>]*>(.-)</[bB]>", "**%1**")
  s = s:gsub("<strong[^>]*>(.-)</strong>", "**%1**")
  s = s:gsub("<[iI]%f[%A][^>]*>(.-)</[iI]>", "*%1*")
  s = s:gsub("<em[^>]*>(.-)</em>", "*%1*")
  s = s:gsub("<code[^>]*>(.-)</code>", "`%1`")

  s = s:gsub("<img([^>]*)>", function(attrs)
    local src = attr(attrs, "src")
    if not src then
      return ""
    end
    return ("![%s](%s)"):format(attr(attrs, "alt") or "", src)
  end)
  s = s:gsub("<a([^>]*)>(.-)</a>", function(attrs, text)
    text = text:gsub("<[^>]->", "")
    local href = attr(attrs, "href")
    if not href then
      return text
    end
    return ("[%s](%s)"):format(text, href)
  end)

  s = s:gsub("<h([1-6])[^>]*>(.-)</h%1>", function(n, text)
    return "\n\n" .. ("#"):rep(tonumber(n)) .. " " .. text .. "\n\n"
  end)
  s = s:gsub("<li[^>]*>%s*", "\n- ")
  s = s:gsub("</?[uo]l[^>]*>", "\n")
  s = s:gsub("<[bB][rR]%s*/?>", "\n")
  s = s:gsub("</?p[^>]*>", "\n\n")
  s = s:gsub("</div>", "\n")

  s = s:gsub("<[^>]->", "")
  s = decode_entities(s)

  s = s:gsub("[ \t]*\n[ \t]*", "\n")
  s = s:gsub("\n\n\n+", "\n\n")
  return vim.trim(s)
end

--- Read the HTML flavor of the system clipboard, or nil if absent.
---@return string?
function M.clipboard_html()
  local cmd
  if vim.fn.has("mac") == 1 then
    cmd = { "osascript", "-e", "the clipboard as «class HTML»" }
  elseif vim.env.WAYLAND_DISPLAY then
    cmd = { "wl-paste", "-t", "text/html" }
  else
    cmd = { "xclip", "-selection", "clipboard", "-t", "text/html", "-o" }
  end
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 or not res.stdout or res.stdout == "" then
    return nil
  end
  local html = res.stdout
  local hex = html:match("«data HTML(%x+)»")
  if hex then
    html = (hex:gsub("%x%x", function(b)
      return string.char(tonumber(b, 16))
    end))
  end
  return html
end

--- Paste the clipboard at the cursor, converting HTML to markdown when available.
--- Falls back to the plain "+ register.
function M.paste()
  local html = M.clipboard_html()
  local text = html and M.html_to_md(html) or vim.fn.getreg("+")
  if text == "" then
    return
  end
  vim.api.nvim_put(vim.split(text, "\n"), "c", true, true)
end

return M
