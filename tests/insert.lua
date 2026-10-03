-- nvim --clean --headless -l tests/insert.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.cmd("runtime plugin/mdpaste.lua")
local mdpaste = require("mdpaste")
local fixture
mdpaste.clipboard_html = function()
  return fixture
end
-- Keep every clipboard read synthetic, including the plain-text fallback.
local plain = ""
vim.fn.getreg = function(reg)
  assert(reg == "+")
  return plain
end
vim.keymap.set({ "n", "i" }, "<D-v>", "<Plug>(mdpaste)")
local cases = {
  { " tail", "i", "<b>foo</b>", "**foo** tail" },
  { "tail", "i", "foo", "footail" },
  { "ab", "a", "foo", "afoob" },
  { "ab", "A", "foo", "abfoo" },
  { "", "i", "foo", "foo" },
  { "  tail", "i", "foo", "foo  tail" },
  { "あtail", "i", "foo", "fooあtail" },
  { " tail", "i", "one<br>two", "one\ntwo tail" },
  { " tail", "", "foo", " footail" }, -- Normal mode retains put-after semantics.
  { " tail", "i", false, "  foo\n bar tail", "  foo\n bar" },
}
for _, c in ipairs(cases) do
  fixture, plain = c[3] or nil, c[5] or ""
  vim.api.nvim_buf_set_lines(0, 0, -1, true, { c[1] })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_feedkeys(vim.keycode(c[2] .. "<D-v><Esc>"), "xt", false)
  local got = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, true), "\n")
  assert(got == c[4], ("keys=%s input=%q want=%q got=%q"):format(c[2], c[1], c[4], got))
end
print(("%d insertion cases OK"):format(#cases))
