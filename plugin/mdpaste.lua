if vim.g.loaded_mdpaste then
  return
end
vim.g.loaded_mdpaste = true

vim.api.nvim_create_user_command("MdPaste", function()
  require("mdpaste").paste()
end, { desc = "Paste clipboard as markdown" })

vim.keymap.set({ "n", "i" }, "<Plug>(mdpaste)", function()
  require("mdpaste").paste()
end, { desc = "Paste clipboard as markdown" })
