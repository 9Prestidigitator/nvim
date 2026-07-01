local tools = require("core.tools")
local env = require("core.env")

require("mason-lspconfig").setup({
	ensure_installed = tools.mason_should_manage_tools() and tools.lsp_servers or {},
	automatic_installation = tools.mason_should_manage_tools(),
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

local on_attach = function(client, bufnr)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "<C-S-k>", vim.lsp.buf.signature_help, bufopts)
end

vim.lsp.enable({
	"rust_analyzer", -- Rust LSP
	"clangd", -- C/C++ LSP
	"ruff", -- Python: Code actions, formatting
	"basedpyright", -- Python: type checking
	"omnisharp", -- C# LSP
	"lua_ls", -- lua LSP
	"bashls", -- bash LSP
	"texlab", -- Latex LSP
	"matlab_ls", -- Matlab Lsp
	"qmlls", -- QML LSP
	"ts_ls", -- TS/JS LSP
	"nixd", -- nix LSP
})

-- LUA
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

-- RUST
vim.lsp.config("rust_analyzer", {
	capabilities = capabilities,
	on_attach = on_attach,
})

-- C/C++
local clangd_cmd
if env.is_nix() and os.getenv("CLANGD_PATH") ~= nil then
	clangd_cmd = vim.env.CLANGD_PATH
else
	clangd_cmd = "clangd"
end

vim.lsp.config("clangd", {
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = {
		clangd_cmd,
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
		"--header-insertion-decorators",
		"--fallback-style=none",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
})

-- PYTHON

local python_on_attach = function(client, bufnr)
	on_attach(client, bufnr)
	if client.name == "ruff" then
		client.server_capabilities.hoverProvider = false
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end
end

vim.lsp.config("ruff", {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	on_attach = python_on_attach,
	init_options = {
		settings = {
			logLevel = "warn",
			lint = {
				enable = true,
			},
			organizeImports = true,
			showSyntaxErrors = true,
			codeAction = {
				disableRuleComment = { enable = false },
				fixViolation = { enable = false },
			},
			format = {
				preview = false,
			},
		},
	},
	single_file_support = false,
})

vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	capabilities = capabilities,
	on_attach = python_on_attach,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				diagnosticSeverityOverrides = {
					reportUnusedImport = "none",
					reportUnusedVariable = "none",
					reportUndefinedVariable = "none",
				},
			},
		},
	},
})

-- C#
vim.lsp.config("omnisharp", {
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = {
		"OmniSharp",
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

-- LATEX
local root_dir_texlab = function(bufnr, cb)
	local root = vim.fs.root(bufnr, {
		".latexmkrc",
		"latexmkrc",
		".texlabroot",
		"texlabroot",
		"Tectonic.toml",
	}) or vim.fn.expand("%:p:h")
	cb(root)
end
local function filter_diagnostics(diagnostics, unwanted_source)
	local filtered = {}
	for _, diag in ipairs(diagnostics) do
		if diag.source ~= unwanted_source then
			table.insert(filtered, diag)
		end
	end
	return filtered
end
local function publishDiagnostics_texlab(err, result, ctx)
	local unwanted_source = "latex"
	result.diagnostics = filter_diagnostics(result.diagnostics, unwanted_source)
	return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
end
vim.lsp.config("texlab", {
	cmd = { "texlab" },
	root_dir = root_dir_texlab,
	filetypes = { "tex", "plaintex", "bib" },
	settings = { -- see https://github.com/latex-lsp/texlab/wiki/Configuration
		texlab = {
			build = {
				onSave = false, -- build on save (it works when :w but not autocmd save)
				forwardSearchAfter = false, -- perform forward search after build
			},
			chktex = { -- show warning about style linting result
				onOpenAndSave = false,
				onEdit = false,
			},
		},
	},
	handlers = {
		-- disable 'latex' source diagnostics
		["textDocument/publishDiagnostics"] = publishDiagnostics_texlab,
	},
})

-- MATLAB
vim.lsp.config("matlab_ls", {
	cmd = { "matlab-language-server", "--stdio" },
	filetypes = { "matlab" },
	settings = {
		matlab = {
			indexWorkspace = true,
			-- installPath = require("jaehak.core.paths").lsp.matlab,
			matlabConnectionTiming = "onStart",
			telemetry = false, -- don't report about any problem
		},
	},
	single_file_support = false, -- if enabled, lsp(matlab.exe) attaches per file, too heavy
})

-- QML
vim.lsp.config("qmlls", {
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = vim.fn.filereadable("/etc/NIXOS") == 1 and { "/run/current-system/sw/bin/qmlls" } or { "qmlls" },
})
