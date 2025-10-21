-- [[
-- OPTIONS
-- ]]

vim.o.backup = false -- Don't create backup files
vim.o.writebackup = false -- Don't create backup before writing
vim.o.undofile = true
vim.o.swapfile = false

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true
vim.o.cursorline = true
vim.o.scrolloff = 2
vim.o.sidescrolloff = 6

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

vim.o.splitbelow = true
vim.o.splitright = true

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
vim.g.netrw_preview = 1
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

	{ src = "https://github.com/vague2k/vague.nvim" }, -- Theme
	{ src = "https://github.com/sphamba/smear-cursor.nvim" }, --Animated Cursor

	{ src = "https://github.com/rmagatti/auto-session" }, -- Saves sessions by directory
	{ src = "https://github.com/nvim-mini/mini.pick" }, -- might replace with telescope, need to do some reading
	{ src = "https://github.com/kylechui/nvim-surround" }, -- Surround plugin
	{ src = "https://github.com/folke/lazydev.nvim" }, -- Makes lua development much better
	{ src = "https://github.com/folke/which-key.nvim" }, -- Because I'm a n00b
	{ src = "https://github.com/windwp/nvim-autopairs" }, -- Saves a lot of time
})

require("mini.pick").setup()
require("smear_cursor").setup({
	-- legacy_computing_symbols_support = true,
	-- trailing_exponent = 0.3,
	-- trailing_stiffness = 0.5,
	-- stiffness = 0.5,
	-- stiffness = 0.6,
	-- trailing_stiffness = 0.25,
	-- trailing_exponent = 0.1,
	-- gamma = 1,
	-- min_horizontal_distance_smear = 2,
	min_vertical_distance_smear = 3,
	-- smear_between_neighbor_lines = false,
	-- cursor_color = require("theme").get_colors().text,
	-- transparent_bg_fallback_color = require("theme").get_colors().base,
})
require("smear_cursor").enabled = true
require("vague").setup({ transparent = true })
require("nvim-surround").setup()
require("auto-session").setup()
require("lazydev").setup()
require("which-key").setup({ preset = "helix" })
require("nvim-autopairs").setup()
require("mason").setup()

-- [[
-- KEYMAPS
-- ]]

local map = vim.keymap.set
map("n", "<A-h>", "<C-w>h", { silent = true })
map("n", "<A-l>", "<C-w>l", { silent = true })
map("n", "<A-j>", "<C-w>j", { silent = true })
map("n", "<A-k>", "<C-w>k", { silent = true })

map("n", "<C-j>", ":m .+1<CR>==", { desc = "Move line down.", silent = true })
map("n", "<C-k>", ":m .-2<CR>==", { desc = "Move line up.", silent = true })
map("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down." })
map("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up." })

map("n", "<leader>e", ":Le<CR>", { desc = "Explorer" })
map("n", "<leader>fr", ":Pick grep_live<CR>", { desc = "ripgrep." })
map("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file in directory." })
map("n", "<leader>fb", ":Pick buffers<CR>", { desc = "Find buffers in session." })
map("n", "<leader>fR", vim.lsp.buf.rename, { desc = "Rename (LSP)." })
map("n", "<leader>fm", vim.lsp.buf.format, { desc = "Format current file." })

map({ "n", "v" }, "<Esc>", ":noh<CR>", { silent = true })
map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard." })
map("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Update and source current file." })
map("n", "<C-s>", ":w<CR>", { desc = "Save (write) file." })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save (write) file." })
map("v", "<", "<gv", { desc = "Indent left and reselect." })
map("v", ">", ">gv", { desc = "Indent right and reselect." })
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
-- DAP Python debugging commands
map("n", "<leader>dpr", function()
	require("dap-python").test_method()
end, { desc = "Debug Python method" })

-- [[
-- Language Features
-- ]]

-- Formatters
require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		lua = { "stylua" },
		python = { "black" },
		cs = { "clang-format" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		javascript = { "prettier" },
	},
})
require("mason-conform").setup()

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
vim.lsp.enable(lsps)
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})
vim.lsp.config("omnisharp", {
	cmd = {
		"dotnet",
		os.getenv("HOME") .. "/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll",
		"--languageserver",
		"--hostPID",
		tostring(vim.fn.getpid()),
	},
	-- Enables support for reading code style, naming convention and analyzer
	-- settings from .editorconfig.
	enable_editorconfig_support = true,
	-- If true, MSBuild project system will only load projects for files that
	-- were opened in the editor. This setting is useful for big C# codebases
	-- and allows for faster initialization of code navigation features only
	-- for projects that are relevant to code that is being edited. With this
	-- setting enabled OmniSharp may load fewer projects and may thus display
	-- incomplete reference lists for symbols.
	enable_ms_build_load_projects_on_demand = false,
	-- Enables support for roslyn analyzers, code fixes and rulesets.
	enable_roslyn_analyzers = false,
	-- Specifies whether 'using' directives should be grouped and sorted during
	-- document formatting.
	organize_imports_on_format = true,
	-- Enables support for showing unimported types and unimported extension
	-- methods in completion lists. When committed, the appropriate using
	-- directive will be added at the top of the current file. This option can
	-- have a negative impact on initial completion responsiveness,
	-- particularly for the first few completion sessions after opening a
	-- solution.
	enable_import_completion = true,
	sdk_include_prereleases = true,
	analyze_open_documents_only = false,
	filetypes = { "cs" },
})

-- DAP
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()
dap.listeners.after.event_initialized.dapui_config = function()
	dapui.open()
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
end

dap.adapters.codelldb = {
	name = "codelldb server",
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}
dap.adapters.coreclr = {
	type = "executable",
	command = os.getenv("HOME") .. "/.local/share/nvim/mason/packages/netcoredbg/netcoredbg",
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		type = "coreclr",
		name = "launch - netcoredbg",
		request = "launch",
		program = function()
			return vim.fn.input("Path to dll", vim.fn.getcwd(), "file")
		end,
	},
}

require("mason-nvim-dap").setup({
	ensure_installed = { "netcoredbg", "debugpy", "codelldb" },
	automatic_installation = true,
})

-- [[
-- LOOK
-- ]]

vim.cmd("colorscheme vague")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#5F8499", bold = false }) -- #51B3EC
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#E388A9", bold = false }) -- #FB508F
vim.api.nvim_set_hl(0, "LineNr", { fg = "#D9D9D9", bold = true })
vim.api.nvim_set_hl(0, "Visual", { fg = "#383c4a", bg = "#BBC5C7", bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#8D95B3" })
