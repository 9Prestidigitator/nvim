vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" }, -- LSPs
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" }, -- Formatter

	{ src = "https://github.com/mfussenegger/nvim-dap" }, -- DAP for Debugging
	{ src = "https://github.com/rcarriga/nvim-dap-ui" }, -- DAP UI
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },

	{ src = "https://github.com/nvim-mini/mini.pick" }, -- might replace with telescope, need to do some reading
	{ src = "https://github.com/folke/lazydev.nvim" }, -- Makes lua development much better
    { src = "https://github.com/lervag/vimtex"}, -- Latex editing

    { src = "https://github.com/nvim-lua/plenary.nvim" }, -- bloatmaxing
	{ src = "https://github.com/rmagatti/auto-session" }, -- Saves sessions by directory
	{ src = "https://github.com/goolord/alpha-nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" }, -- Saves a lot of time
	{ src = "https://github.com/kylechui/nvim-surround" }, -- Surround plugin
	{ src = "https://github.com/folke/which-key.nvim" }, -- Because I'm a n00b
    { src = "https://github.com/MunifTanjim/nui.nvim" }, -- ui stuff for leetcode
	{ src = "https://github.com/kdheepak/lazygit.nvim" },
	{ src = "https://github.com/epwalsh/obsidian.nvim" },
	{ src = "https://github.com/kawre/leetcode.nvim" },

	{ src = "https://github.com/stevearc/oil.nvim" }, -- File Explorer
	{ src = "https://github.com/SirZenith/oil-vcs-status" },

	{ src = "https://github.com/mason-org/mason.nvim" }, -- Loads LSP's, DAP's, linters, and formatters
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" }, -- Autoloads LSP's for Mason
    { src = "https://github.com/zapling/mason-conform.nvim" }, -- Autoloads formatters for Mason
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" }, -- DAP Mason integration

	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	{ src = "https://github.com/hrsh7th/cmp-cmdline" },

	{ src = "https://github.com/vague2k/vague.nvim" }, -- Theme
    { src = "https://github.com/nvim-lualine/lualine.nvim" }, -- status line
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/sphamba/smear-cursor.nvim" }, --Animated Cursor
    { src = "https://github.com/OXY2DEV/markview.nvim" },
    { src = "https://github.com/nvim-mini/mini.icons" }, -- Icons
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- webdev icons
})

require("mason").setup()

require("plugins.mini-pick")
require("plugins.alpha")
require("plugins.lsp")
require("plugins.conform")
require("plugins.dap")
require("plugins.oil")
require("plugins.cmp")
require("plugins.lualine")
require("plugins.which-key")
require("plugins.auto-sessions")
require("plugins.smear-cursor")

require("leetcode").setup({
	lang = "rust",
})
require("plugins.vimtex")
require("markview").setup()
require("obsidian").setup({
	workspaces = {
		{
			name = "notes",
			path = "~/notes",
		},
	},
	ui = {
		enable = false,
	},
})
require("fidget").setup()
require("vague").setup({ transparent = true })
require("nvim-surround").setup()
require("nvim-autopairs").setup()
require("mini.icons").setup()
require("nvim-web-devicons").setup()
require("gitsigns").setup()
require("lazydev").setup()
