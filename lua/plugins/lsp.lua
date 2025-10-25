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

