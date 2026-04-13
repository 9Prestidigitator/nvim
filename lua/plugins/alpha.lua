local dashboard = require("alpha.themes.dashboard")

local logo = [[


   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆
    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦
          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄
           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄
          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀
   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄
  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄
 ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄
 ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄
      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆
       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃
]]

dashboard.section.header.val = vim.split(logo, "\n")
dashboard.section.buttons.val = {
	dashboard.button("n", " " .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
	dashboard.button("r", " " .. " Recent files", [[<cmd>PickRecentFiles<cr>]]),
	dashboard.button("d", " " .. " Recent Sessions", [[<cmd>AutoSession search<cr>]]),
	dashboard.button("g", " " .. " Find text", [[<cmd>Pick grep_live<cr>]]),
	dashboard.button("f", " " .. " Find file", "<cmd>Pick files<cr>"),
	dashboard.button("e", " " .. " File explorer", ":Oil<CR>"),
	dashboard.button("c", " " .. " Config", function()
		vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.stdpath("config")))
		vim.cmd("AutoSession restore")
	end),
	dashboard.button("l", "󰊢 " .. " LazyGit", ":LazyGit<CR>"),
	dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
}
dashboard.opts.cursorline = false

require("alpha").setup(dashboard.opts)
