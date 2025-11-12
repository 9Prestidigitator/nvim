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
		json = { "jq" },
		nix = { "alejandra" },
		toml = { "taplo" },
		markdown = { "prettierd" },
		css = { "prettierd" },
		yaml = { "prettierd" },
		html = { "prettierd" },
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
