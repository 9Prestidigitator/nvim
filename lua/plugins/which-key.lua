require("which-key").setup({
	preset = "helix",
	spec = {
		{
			mode = { "n", "x" },
			{ "<leader>", group = "Leader" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>f", group = "Find" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>w", group = "Tabs" },
			{ "<leader>l", group = "lazy" },
			{ "<leader>v", group = "Vimtex" },
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "gr", group = "LSP" },
			{ "ys", group = "surround" },
			{ "z", group = "fold" },
		},
	},
})
