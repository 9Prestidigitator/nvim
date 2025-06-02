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
vim.opt.termguicolors = true

-- notifications
vim.notify = require("notify")
require("notify").setup({
  background_color="#000000",
})

-- change directory and restore previous buffers 
vim.api.nvim_create_user_command("CdAndRestore", function()
  vim.ui.input({ prompt = "Change directory to: " }, function(dir)
    if dir and vim.fn.isdirectory(dir) == 1 then
      vim.cmd("cd " .. dir)
      print("Changed to: " .. vim.fn.getcwd())
      vim.cmd("SessionRestore")
    else
      print("Invalid directory")
    end
  end)
end, {})

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- require("luasnip.loaders.from_lua").lazy_load({
--   paths = { "~/.config/nvim/lua/snippets" },
-- })

