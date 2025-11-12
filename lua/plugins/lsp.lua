require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls", -- lua LSP
		"bashls", -- bash LSP
		"basedpyright", -- Python LSP
		"ruff", -- Extra Python functionality
		"clangd", -- c/c++ LSP
		"omnisharp", -- c# LSP
		"rust_analyzer", -- rust LSP
	},
	automatic_installation = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

local on_attach = function(client, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "<C-K>", vim.lsp.buf.signature_help, bufopts)
end

vim.lsp.enable({
	"lua_ls", -- lua LSP
	"bashls", -- bash LSP
	"basedpyright", -- Python LSP
	"ruff", -- Extra Python functionality
	"clangd", -- c/c++ LSP
	"omnisharp", -- c# LSP
	"rust_analyzer", -- rust LSP
	"nixd", -- nix LSP
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

vim.lsp.config("rust_analyzer", {
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.lsp.config("clangd", {
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "c", "cpp" },
})

vim.lsp.config("basedpyright", {
    capabilities = capabilities,
    on_attach = on_attach,
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

vim.lsp.config("omnisharp", {
	capabilities = capabilities,
	on_attach = on_attach,
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

