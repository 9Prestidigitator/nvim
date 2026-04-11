local env = require("core.env")
local o = vim.opt

o.backup = false -- Don't create backup files
o.writebackup = false -- Don't create backup before writing
o.undofile = true
o.swapfile = false
o.showmode = false

o.number = true
o.relativenumber = true
o.wrap = true
o.scrolloff = 2
o.sidescrolloff = 6
o.cursorline = true

o.fillchars = "eob: "

o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = false

o.termguicolors = true
o.winborder = "rounded"
o.signcolumn = "yes"

o.laststatus = 3
o.splitbelow = true
o.splitright = true
o.timeoutlen = vim.g.vscode and 1000 or 300
if env.is_nixos() and vim.fn.executable("/run/current-system/sw/bin/bash") == 1 then
	o.shell = "/run/current-system/sw/bin/bash"
end
