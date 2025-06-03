require "nvchad.options"

require "pythonconf"

-- Enable treesitter based folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- notifications
vim.notify = require "notify"

-- Optional: start with folds open
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- relative line numbers
vim.opt.relativenumber = true
vim.opt.scrolloff = 1
vim.opt.termguicolors = true

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- require("luasnip.loaders.from_lua").lazy_load({
--   paths = { "~/.config/nvim/lua/snippets" },
-- })

