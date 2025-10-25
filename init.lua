-- [[
-- OPTIONS
-- ]]

vim.o.backup = false -- Don't create backup files
vim.o.writebackup = false -- Don't create backup before writing
vim.o.undofile = true
vim.o.swapfile = false
vim.o.showmode = false

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true
vim.o.scrolloff = 2
vim.o.sidescrolloff = 6
vim.o.cursorline = true
local cursorline_exclude = { "alpha", "TelescopePrompt", "oil" }
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, { -- Disable in inactive windows
	group = cursorline_group,
	callback = function()
		local ft = vim.bo.filetype
		local excluded = vim.tbl_contains(cursorline_exclude, ft)
		if excluded then
			vim.opt_local.cursorline = false
		else
			vim.opt_local.cursorline = true
		end
	end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = cursorline_group,
	callback = function()
		vim.opt_local.cursorline = false
	end,
})
vim.o.fillchars = "eob: "

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = false

vim.o.termguicolors = true
vim.o.winborder = "rounded"
vim.o.signcolumn = "yes"

vim.o.laststatus = 3
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = vim.g.vscode and 1000 or 300

-- [[
-- GLOBALS
-- ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_banner = 0 -- toggle with I
vim.g.netrw_sizestyle = "H"
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_localcopydircmd = "cp -r"
vim.g.netrw_preview = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_fastbrowse = 0

-- [[
-- PLUGINS
-- ]]

vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" }, -- LSPs
	{ src = "https://github.com/mason-org/mason.nvim" }, -- Loads LSP's, DAP's, linters, and formatters
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" }, -- Autoloads LSP's for Mason

	{ src = "https://github.com/stevearc/conform.nvim" }, -- Formatter
	{ src = "https://github.com/zapling/mason-conform.nvim" }, -- Autoloads formatters for Mason

	{ src = "https://github.com/mfussenegger/nvim-dap" }, -- DAP for Debugging
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" }, -- DAP Mason integration
	{ src = "https://github.com/rcarriga/nvim-dap-ui" }, -- DAP UI
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },

	{ src = "https://github.com/vague2k/vague.nvim" }, -- Theme
	{ src = "https://github.com/sphamba/smear-cursor.nvim" }, --Animated Cursor
	{ src = "https://github.com/goolord/alpha-nvim" },
	{ src = "https://github.com/rmagatti/auto-session" }, -- Saves sessions by directory
	{ src = "https://github.com/nvim-mini/mini.pick" }, -- might replace with telescope, need to do some reading
	{ src = "https://github.com/nvim-mini/mini.icons" }, -- Icons
	{ src = "https://github.com/kylechui/nvim-surround" }, -- Surround plugin
	{ src = "https://github.com/folke/lazydev.nvim" }, -- Makes lua development much better
	{ src = "https://github.com/folke/which-key.nvim" }, -- Because I'm a n00b
	{ src = "https://github.com/windwp/nvim-autopairs" }, -- Saves a lot of time
	{ src = "https://github.com/stevearc/oil.nvim" }, -- File Explorer
	{ src = "https://github.com/SirZenith/oil-vcs-status" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/kdheepak/lazygit.nvim" },
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	{ src = "https://github.com/hrsh7th/cmp-cmdline" },
})

require("mini.pick").setup({
	mappings = {
		toggle_info = "<C-k>",
		toggle_preview = "<C-p>",
		move_down = "<Tab>",
		move_up = "<S-Tab>",
	},
})
require("cmp").setup({
	snippet = {
		expand = function(args)
			-- Don't expand snippets, just insert the text
			vim.snippet.expand(args.body)
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = require("cmp").mapping.preset.insert({
		["<C-n>"] = require("cmp").mapping.select_next_item(),
		["<C-p>"] = require("cmp").mapping.select_prev_item(),
		["<C-b>"] = require("cmp").mapping.scroll_docs(-4),
		["<C-f>"] = require("cmp").mapping.scroll_docs(4),
		["<C-Space>"] = require("cmp").mapping.complete(),
		["<C-e>"] = require("cmp").mapping.abort(),
		["<C-y>"] = require("cmp").mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = require("cmp").mapping(function(fallback)
			if require("cmp").visible() then
				require("cmp").select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = require("cmp").mapping(function(fallback)
			if require("cmp").visible() then
				require("cmp").select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = require("cmp").config.sources({
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})
vim.api.nvim_create_user_command("PickRecentFiles", function()
	local pick = require("mini.pick")
	local icons = require("mini.icons")
	local oldfiles = vim.v.oldfiles or {}
	local files = vim.tbl_filter(function(f)
		return vim.fn.filereadable(f) == 1 -- Filter only readable files
	end, oldfiles)
	local items = vim.tbl_map(function(path)
		local icon, _ = icons.get("file", vim.fn.fnamemodify(path, ":t"))
		return string.format("%s %s", icon or " ", path)
	end, files)
	pick.start({
		source = {
			name = "Recent Files",
			items = items,
			choose = function(item)
				local path = item:match("^.-%s+(.*)$")
				vim.schedule(function()
					vim.cmd("edit " .. vim.fn.fnameescape(path))
				end)
			end,
		},
	})
end, {})

vim.api.nvim_create_user_command("PickKeymaps", function()
	local pick = require("mini.pick")
	local mode_names = {
		n = "Normal",
		i = "Insert",
		v = "Visual",
		x = "Visual",
		s = "Select",
		o = "Operator-pending",
		c = "Command-line",
		t = "Terminal",
	}
	local all_modes = { "n", "i", "v", "x", "s", "o", "c", "t" }
	local items = {}

	for _, mode in ipairs(all_modes) do
		local maps = vim.api.nvim_get_keymap(mode)
		for _, map in ipairs(maps) do
			local mode_label = mode_names[mode] or mode
			local desc = map.desc or ""
			table.insert(items, string.format("[%s] %-15s → %-40s %s", mode_label, map.lhs, map.rhs, desc))
		end
	end

	pick.start({
		source = {
			name = "Keymaps",
			items = items,
			choose = function(item)
				local lhs = item:match("%] (%S+)")
				vim.cmd("verbose map " .. lhs)
			end,
		},
		window = {
			config = {
				width = 120,
			},
		},
	})
end, {})

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
	dashboard.button("c", " " .. " Config", "<cmd>cd ~/.config/nvim | AutoSession restore<cr>"),
	dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
}
dashboard.opts.cursorline = false
require("alpha").setup(dashboard.opts)
require("lualine").setup({
	theme = "nord",
	options = {
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
	},
})
require("gitsigns").setup()
require("smear_cursor").setup()
require("smear_cursor").enabled = true
require("vague").setup({ transparent = true })
require("nvim-surround").setup()
require("mason").setup()
require("lazydev").setup()
require("nvim-autopairs").setup()
require("mini.icons").setup()
require("auto-session").setup({
	auto_session_suppress_dirs = {
		"~/",
		"~/Documents",
		"~/Downloads",
	},
})
require("oil").setup({
	default_file_explorer = true,
	view_options = {
		show_hidden = true,
	},
	win_options = {
		signcolumn = "number",
	},
	keymaps = {
		["<leader>e"] = { "actions.close", mode = "n" },
	},
})
local StatusType = require("oil-vcs-status.constant.status").StatusType
require("oil-vcs-status").setup({
	status_symbol = {
		[StatusType.Added] = "",
		[StatusType.Copied] = "󰆏",
		[StatusType.Deleted] = "",
		[StatusType.Ignored] = "",
		[StatusType.Modified] = "",
		[StatusType.Renamed] = "",
		[StatusType.TypeChanged] = "󰉺",
		[StatusType.Unmodified] = " ",
		[StatusType.Unmerged] = "",
		[StatusType.Untracked] = "",
		[StatusType.External] = "",

		[StatusType.UpstreamAdded] = "󰈞",
		[StatusType.UpstreamCopied] = "󰈢",
		[StatusType.UpstreamDeleted] = "",
		[StatusType.UpstreamIgnored] = " ",
		[StatusType.UpstreamModified] = "󰏫",
		[StatusType.UpstreamRenamed] = "",
		[StatusType.UpstreamTypeChanged] = "󱧶",
		[StatusType.UpstreamUnmodified] = " ",
		[StatusType.UpstreamUnmerged] = "",
		[StatusType.UpstreamUntracked] = " ",
		[StatusType.UpstreamExternal] = "",
	},
})
require("which-key").setup({
	preset = "helix",
	spec = {
		{
			mode = { "n", "x" },
			{ "<leader>", group = "Leader" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>f", group = "Find" },
			{ "<leader>b", group = "Buffer" },
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "gr", group = "LSP" },
			{ "ys", group = "surround" },
			{ "z", group = "fold" },
		},
	},
})

-- [[
-- KEYMAPS
-- ]]

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
map("n", "<leader>fg", ":Pick grep_live<CR>", { desc = "Find via ripgrep." })
map("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file in directory." })
map("n", "<leader>fb", ":Pick buffers<CR>", { desc = "Find buffers in session." })
map("n", "<leader>fr", ":PickRecentFiles<CR>", { desc = "Find recent files." })
map("n", "<leader>fh", ":Pick help<CR>", { desc = "Find help." })
map("n", "<leader>fm", ":PickKeymaps<CR>", { desc = "Find mappings." })
map("n", "<leader>lg", ":LazyGit<CR>", { desc = "Lazygit" })
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

_G.term_win_id = nil -- Store the window ID in a global variable to track it
_G.term_buf_id = nil
function _G.ToggleTerminal() -- This is the main function to toggle the terminal
	-- Check if the stored window ID is still valid
	if _G.term_win_id and vim.api.nvim_win_is_valid(_G.term_win_id) then
		-- Hide the window and clear our variable
		vim.api.nvim_win_hide(_G.term_win_id)
		_G.term_win_id = nil
	else
		-- If not, create a new terminal (or reuse existing buffer)
		vim.cmd("botright 12split")
		-- Check if we have a valid terminal buffer stored
		if _G.term_buf_id and vim.api.nvim_buf_is_valid(_G.term_buf_id) then
			-- Reuse the existing terminal buffer
			vim.api.nvim_win_set_buf(0, _G.term_buf_id)
		else
			-- Create a new terminal
			vim.cmd("terminal")
			_G.term_buf_id = vim.api.nvim_get_current_buf()
		end
		vim.cmd("startinsert")
		_G.term_win_id = vim.api.nvim_get_current_win() -- Store the new window's ID
	end
end

vim.api.nvim_create_autocmd("TermOpen", { -- Setup keymaps inside the terminal
	pattern = "*",
	callback = function(ctx)
		vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = ctx.buf, silent = true, desc = "Exit terminal mode" })
		vim.keymap.set(
			"t",
			"<C-t>",
			"<C-\\><C-n><Cmd>lua _G.ToggleTerminal()<CR>",
			{ buffer = ctx.buf, silent = true, desc = "Toggle terminal" }
		)
	end,
})
-- Map a key in NORMAL mode to open/close the terminal
vim.keymap.set("n", "<leader>t", _G.ToggleTerminal, { desc = "Toggle terminal" })

-- [[
-- Language Features
-- ]]

-- Formatters
require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		lua = { "stylua" },
		python = { "black" },
		cs = { "csharpier" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		javascript = { "prettier" },
	},
})
require("mason-conform").setup()
vim.keymap.del("n", "grf")
vim.keymap.set("n", "grf", function()
	local conform = require("conform")
	if not conform.format({ async = true, lsp_fallback = true }) then
		vim.lsp.buf.format({ async = true }) -- Try conform first, fall back to LSP
	end
end, { desc = "vim.lsp.buf.format() [Conform first]" })

-- Might add linters later however LSPs will do for now

-- LSP's
local lsps = {
	"lua_ls", -- lua LSP
	"bashls", -- bash LSP
	"pyright", -- Python LSP
	"clangd", -- c/c++ LSP
	"omnisharp", -- c# LSP
	"bacon_ls", -- rust LSP
}
require("mason-lspconfig").setup({
	ensure_installed = lsps,
	automatic_installation = true,
})
local capabilities = vim.lsp.protocol.make_client_capabilities()
vim.lsp.enable(lsps)
vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})
vim.lsp.config("clangd", {
	capabilities = capabilities,
	filetypes = { "c", "cpp" },
})
vim.lsp.config("omnisharp", {
	capabilities = capabilities,
	cmd = {
		"dotnet",
		os.getenv("HOME") .. "/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll",
		"--languageserver",
		"--hostPID",
		tostring(vim.fn.getpid()),
	},
	enable_editorconfig_support = true,
	enable_ms_build_load_projects_on_demand = false,
	enable_roslyn_analyzers = false,
	organize_imports_on_format = true,
	enable_import_completion = true,
	sdk_include_prereleases = true,
	analyze_open_documents_only = false,
	filetypes = { "cs" },
})
vim.lsp.config("pyright", {
	capabilities = capabilities,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
				typeCheckingMode = "basic", -- or "off", "strict"
			},
		},
	},
})

-- DAP
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized.dapui_config = function()
	dapui.open()
	vim.keymap.set("n", "<leader>du", function()
		dapui.open({ reset = true })
	end, { desc = "Reset DAP ui." })
end
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
	vim.keymap.del("n", "<leader>du")
end

require("dap-python").setup(os.getenv("HOME") .. "/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
dap.configurations.python = {
	{
		name = "Debug python file",
		type = "python",
		request = "launch",
		program = "${file}",
		pythonPath = function()
			local conda_path = vim.env.CONDA_PREFIX
			if conda_path then
				-- Use conda path if available
				return conda_path .. "/bin/python"
			else
				-- Use the virtualenv if available
				local venv_path = os.getenv("VIRTUAL_ENV")
				if venv_path then
					return venv_path .. "/bin/python"
				else
					return "/usr/bin/python"
				end
			end
		end,
	},
}

dap.adapters.codelldb = {
	name = "Launch codelldb server",
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}
dap.configurations.cpp = {
	name = "Debug c++ binary",
	type = "codelldb",
	request = "launch",
	program = function()
		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	end,
}

dap.adapters.coreclr = {
	name = "Launch netcoredbg binary",
	type = "executable",
	command = os.getenv("HOME") .. "/.local/share/nvim/mason/packages/netcoredbg/netcoredbg",
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		name = "Debug c# dll",
		type = "coreclr",
		request = "launch",
		program = function()
			return vim.fn.input("Path to dll", vim.fn.getcwd(), "file")
		end,
	},
}

require("mason-nvim-dap").setup({ automatic_installation = true })

-- [[
-- UI
-- ]]

vim.cmd("colorscheme vague")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#5F8499", bold = false }) -- #51B3EC
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#E388A9", bold = false }) -- #FB508F
vim.api.nvim_set_hl(0, "LineNr", { fg = "#D9D9D9", bold = true })
vim.api.nvim_set_hl(0, "Visual", { fg = "#383c4a", bg = "#BBC5C7", bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#8D95B3" })
-- Debugger Customization
vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DapBreakpoint",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
	text = "",
	texthl = "DapBreakpointCondition",
	linehl = "",
	numhl = "",
})
vim.fn.sign_define("DapStopped", {
	text = "",
	texthl = "DapStopped",
	linehl = "",
	numhl = "",
})
vim.api.nvim_set_hl(0, "DapBreakpoint", {
	fg = "#f38ba8",
	bg = "NONE",
	bold = true,
})
vim.api.nvim_set_hl(0, "DapBreakpointCondition", {
	fg = "#f38ba8",
	bg = "NONE",
	bold = true,
})
vim.api.nvim_set_hl(0, "DapStopped", {
	fg = "#f9e3e4",
	bg = "NONE",
})
