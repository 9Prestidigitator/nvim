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

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
