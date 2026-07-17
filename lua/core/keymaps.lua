local map = vim.keymap.set
local terminal = require("core.terminal")
local float_tui = require("core.float_tui")
terminal.setup()

-- Portals
float_tui.setup({
	apps = {
		lazygit = {
			cmd = "lazygit",
			key = "<leader>lg",
			desc = "LazyGit",
			title = " lazygit ",
			filetype = "lazygit",
			command = "FloatTuiLazyGit",
		},
		lazyjj = {
			cmd = "lazyjj",
			key = "<leader>lj",
			desc = "LazyJJ",
			title = " lazyjj ",
			filetype = "lazyjj",
			command = "FloatTuiLazyJJ",
		},
		lazydocker = {
			cmd = "lazydocker",
			key = "<leader>ld",
			desc = "LazyDocker",
			title = " lazydocker ",
			filetype = "lazydocker",
			command = "FloatTuiLazyDocker",
		},
		k9s = {
			cmd = "k9s",
			key = "<leader>lk",
			desc = "k9s",
			title = " k9s ",
			filetype = "k9s",
			command = "FloatTuiLazyK9s",
		},
		lazysql = {
			cmd = "lazysql",
			key = "<leader>lq",
			desc = "lazysql",
			title = " lazysql ",
			filetype = "lazysql",
			command = "FloatTuiLazySql",
		},
		vd = {
			cmd = "vd",
			key = "<leader>lv",
			desc = "vd",
			title = " vd ",
			filetype = "vd",
			command = "FloatTuiVd",
		},
		btop = {
			cmd = "btop",
			key = "<leader>lt",
			desc = "btop",
			title = " btop ",
			filetype = "btop",
			command = "FloatTuiBtop",
		},
		ncdu = {
			cmd = "ncdu",
			key = "<leader>ln",
			desc = "ncdu",
			title = " ncdu ",
			filetype = "ncdu",
			command = "FloatTuiNcdu",
		},
		pwtop = {
			cmd = "pw-top",
			key = "<leader>lp",
			desc = "pipewire",
			title = " pipewire ",
			filetype = "pipewire",
			command = "FloatTuiPwTop",
		},
		rmpc = {
			cmd = "rmpc",
			key = "<leader>lr",
			desc = "rmpc",
			title = " rmpc ",
			filetype = "rmpc",
			command = "FloatTuiRmpc",
		},
		codex = {
			cmd = "codex",
			key = "<leader>lc",
			desc = "codex",
			title = " codex ",
			filetype = "codex",
			command = "FloatTuiCodex",
		},
		hermes = {
			cmd = "hermes",
			key = "<leader>lh",
			desc = "hermes",
			title = " hermes ",
			filetype = "hermes",
			command = "FloatTuiCodex",
		},
	},
})
map("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Explorer" })
map("n", "<leader>A", "<CMD>Alpha<CR>", { desc = "Home" })
map("n", "<leader>u", function()
	vim.cmd("packadd nvim.undotree")
	vim.cmd("Undotree")
end, { desc = "Undotree" })
map("n", "<leader>xe", function()
	local dir = vim.fn.getcwd()
	vim.fn.jobstart({ "xdg-open", dir }, { detach = true })
end, { desc = "Open cwd in system file explorer" })

-- Terminals
map("n", "<leader>th", function()
	terminal.toggle("left")
end, { desc = "Terminal left" })
map("n", "<leader>tl", function()
	terminal.toggle("right")
end, { desc = "Terminal right" })
map("n", "<leader>tj", function()
	terminal.toggle("bottom")
end, { desc = "Terminal bottom" })
map("n", "<leader>tk", function()
	terminal.toggle("top")
end, { desc = "Toggle top" })
map("n", "<leader>tg", function()
	terminal.toggle("float")
end, { desc = "Terminal float" })
map("n", "<leader>tt", function()
	terminal.toggle()
end, { desc = "Toggle terminal" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })

-- Line swapping
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Swap line down", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Swap line up", silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Swap selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Swap selection up" })

-- Find
map("n", "<leader>fg", ":Pick grep_live<CR>", { desc = "Find via ripgrep" })
map("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file in directory" })
map("n", "<leader>fF", ":PickAllFiles<CR>", { desc = "Find all files in dir" })
map("n", "<leader>fb", ":Pick buffers<CR>", { desc = "Find buffers in session" })
map("n", "<leader>fr", ":PickRecentFiles<CR>", { desc = "Find recent files" })
map("n", "<leader>fh", ":Pick help<CR>", { desc = "Find help" })
map("n", "<leader>fm", ":PickKeymaps<CR>", { desc = "Find mappings" })
map("n", "<leader>ft", ":PickTabs<CR>", { desc = "Find tabs" })

-- Flash
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
map("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })
map("c", "<C-s>", function()
	require("flash").toggle()
end, { desc = "Toggle Flash Search" })

-- Buffer binds
map("n", "<leader>bw", ":bw<CR>", { desc = "Wipeout Buffer" })
map("n", "<leader>bx", ":bdelete<CR>", { desc = "Delete Buffer" })
map("n", "<leader>bX", ":bdelete!<CR>", { desc = "Force Delete Buffer" })
map("n", "<leader>bb", ":buffers<CR>", { desc = "Show buffers" })
map("n", "<leader>bB", ":buffers!<CR>", { desc = "Show all buffers" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Tab binds
map("n", "<leader>ww", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>wq", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>wn", ":tabmove +1<CR>", { desc = "Move tab right" })
map("n", "<leader>wp", ":tabmove -1<CR>", { desc = "Move tab left" })
map("n", "<leader>wg", ":tabmove 0<CR>", { desc = "Move current tab to beginning" })
map("n", "<leader>wG", ":tabmove<CR>", { desc = "Move current tab to end" })

-- Backup LSP commands
map("n", "grf", vim.lsp.buf.format, { desc = "lsp: format" })
map("n", "grd", vim.lsp.buf.definition, { desc = "lsp: definition" })
map("n", "grk", vim.lsp.buf.hover, { desc = "lsp: hover" })
map("n", "grw", function()
	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List LSP workspace folders." })

-- Quick commenting
map({ "n" }, "<leader>/", "gcc", { desc = "Toggle Comment", remap = true })
map({ "v" }, "<leader>/", "gc", { desc = "Toggle Comment", remap = true })

-- <C-s> to save as universal default, just intuitive for me
map("n", "<C-s>", "<CMD>w<CR>", { desc = "Save (write) file" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save (write) file" })

-- System clipboard
map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })

-- Indentation
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Cursor centering
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "<A-m>", function()
	local line = vim.api.nvim_get_current_line()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local first_char = line:find("%S")
	if first_char then
		local trimmed = line:match("^%s*(.-)%s*$")
		local content_len = #trimmed
		local center_col = first_char + math.floor(content_len / 2) - 1
		vim.api.nvim_win_set_cursor(0, { row, center_col })
	end
end, { desc = "Cursor to center of line" })

-- DAP Debugging commands
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <cr>", { desc = "Add breakpoint at line" })
map("n", "<leader>dq", "<cmd> DapClearBreakpoints <cr>", { desc = "Clear all Breakpoints" })
map("n", "<leader>dr", "<cmd> DapContinue <cr>", { desc = "Start or continue the debugger" })
map("n", "<leader>dl", "<cmd> DapStepOver <cr>", { desc = "Debugger: Step over" })
map("n", "<leader>dk", "<cmd> DapStepOut <cr>", { desc = "Debugger: Step Out" })
map("n", "<leader>dj", "<cmd> DapStepInto <cr>", { desc = "Debugger: Step Into" })
map("n", "<leader>dc", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Add conditional breakpoint" })
map("n", "<leader>dx", function()
	require("dap").terminate()
	require("dap").disconnect()
end, { desc = "Debugger: Quit" })
vim.keymap.set("n", "<leader>du", function()
	require("dapui").open({ reset = true })
end, { desc = "Reset DAP ui." })

-- etc
map("n", "<Esc>", "<CMD>noh<CR>", { silent = true })
map("i", "<C-h>", "<C-W>", { desc = "Delete word" })
map("n", "<C-c>", "<C-a>", { desc = "Increment next number" })
