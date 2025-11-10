local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down.", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up.", silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down." })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up." })

map("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Explorer" })
map("n", "<leader>A", "<CMD>Alpha<CR>", { desc = "Home" })
map("n", "<leader>lg", ":LazyGit<CR>", { desc = "Lazygit" })

map("n", "<leader>fg", ":Pick grep_live<CR>", { desc = "Find via ripgrep." })
map("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file in directory." })
map("n", "<leader>fb", ":Pick buffers<CR>", { desc = "Find buffers in session." })
map("n", "<leader>fr", ":PickRecentFiles<CR>", { desc = "Find recent files." })
map("n", "<leader>fh", ":Pick help<CR>", { desc = "Find help." })
map("n", "<leader>fm", ":PickKeymaps<CR>", { desc = "Find mappings." })

map("n", "<leader>bw", ":bw<CR>", { desc = "Wipeout Buffer." })
map("n", "<leader>bx", ":bdelete<CR>", { desc = "Delete Buffer." })
map("n", "<leader>bX", ":bdelete!<CR>", { desc = "Force Delete Buffer." })
map("n", "<leader>bb", ":buffers<CR>", { desc = "Show buffers." })
map("n", "<leader>bB", ":buffers!<CR>", { desc = "Show all buffers." })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer." })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer." })

map("n", "grf", vim.lsp.buf.format, { desc = "vim.lsp.buf.format()" })
map("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })

map({ "n" }, "<leader>/", "gcc", { desc = "Toggle Comment", remap = true })
map({ "v" }, "<leader>/", "gc", { desc = "Toggle Comment", remap = true })
map({ "n" }, "<Esc>", "<CMD>noh<CR>", { silent = true })

map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map("n", "<C-s>", "<CMD>w<CR>", { desc = "Save (write) file." })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save (write) file." })
map("v", "<", "<gv", { desc = "Indent left and reselect." })
map("v", ">", ">gv", { desc = "Indent right and reselect." })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("i", "<C-h>", "<C-W>", { desc = "Delete word" })
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

-- Map a key in NORMAL mode to open/close the terminal
map("n", "<leader>t", _G.ToggleTerminal, { desc = "Toggle terminal" })
