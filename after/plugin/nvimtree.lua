local nvimTree = require("nvim-tree")
-- disable netrw at the very start of your init.lua
nvimTree.disable_netrw = false
nvimTree.hijack_netrw  = true
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- OR setup with some options
nvimTree.setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 50,
  },
  renderer = {
    group_empty = true,
  },
  git = {
      enable = true,
      ignore = false,
      timeout = 500,
  }
})
