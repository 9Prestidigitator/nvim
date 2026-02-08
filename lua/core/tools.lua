local env = require("core.env")

local M = {}

M.lsp_servers = {
	"rust_analyzer", -- Rust LSP
	"clangd", -- C/C++ LSP
	"basedpyright", -- Python: type checking
	"ruff", -- Python: Code actions, formatting
	"omnisharp", -- C# LSP
	"lua_ls", -- lua LSP
	"bashls", -- bash LSP
	"texlab", -- Latex LSP
	"matlab_ls", -- Matlab LSP
	"qmlls", -- QML LSP (nix: qt6.qtdeclarative)
	"ts_ls", -- TS/JS LSP
}

M.formatters = {
	"alejandra",
	"stylua",
	"csharpier",
	"prettier",
	"prettierd",
	"black",
	"tex-fmt",
	"jq",
	"taplo",
	"shfmt",
	"clang-format",
}

function M.mason_should_manage_tools()
	return not env.is_nix()
end

function M.mason_ignore_install()
	if env.is_nix() then
		return M.formatters
	end
	return {}
end

return M
