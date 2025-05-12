require "nvchad.options"

require "pythonconf"

-- Enable treesitter based folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- Optional: start with folds open
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- relative line numbers
vim.opt.relativenumber = true
vim.opt.scrolloff = 1

vim.api.nvim_set_hl(0, "TabLine", {
  -- fg = "#7f849c", -- a light greyish color
  fg = "#cdd6f4",
  bold = false,
})
-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
