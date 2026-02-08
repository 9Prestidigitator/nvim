local tools = require("core.tools")

-- Formatters
require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		lua = { "stylua" },
		python = { "black" },
		cs = { "csharpier" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		nix = { "alejandra" },
		tex = { "tex-fmt" },
		matlab = { lsp_format = "first" },
		javascript = { "prettier" },
		json = { "jq" },
		toml = { "taplo" },
		css = { "prettierd" },
		markdown = { "prettierd" },
		html = { "prettierd" },
		yaml = { "prettierd" },
	},
})

require("mason-conform").setup({
	ignore_install = tools.mason_ignore_install(),
})

vim.keymap.del("n", "grf")
vim.keymap.set("n", "grf", function()
	local conform = require("conform")
	if not conform.format({ async = true, lsp_fallback = true }) then
		vim.lsp.buf.format({ async = true }) -- Try conform first, fall back to LSP
	end
end, { desc = "vim.lsp.buf.format() [Conform first]" })
