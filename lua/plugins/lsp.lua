local function is_nixos()
	return vim.fn.filereadable("/etc/NIXOS") == 1
end

require("mason-lspconfig").setup({
	ensure_installed = (function()
		local servers = {
			"lua_ls", -- lua LSP
			"qmlls", -- QML LSP
		}
		if not is_nixos() then
			table.insert(servers, "clangd") -- c/c++ LSP
			table.insert(servers, "basedpyright") -- Python: type checking
			table.insert(servers, "ruff") -- Python: Code actions, formatting
			table.insert(servers, "matlab_ls") -- Matlab LSP
			table.insert(servers, "texlab") -- Latex LSP
			table.insert(servers, "rust_analyzer") -- rust LSP
			table.insert(servers, "bashls") -- bash LSP
			table.insert(servers, "ts_ls") -- TS/JS LSP
			table.insert(servers, "omnisharp") -- C# LSP
		end
		return servers
	end)(),
	automatic_installation = true,
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
	"bashls", -- bash LSP
	"lua_ls", -- lua LSP
	"rust_analyzer", -- rust LSP
	"clangd", -- c/c++ LSP
	"ruff", -- Python: Code actions, formatting
	"basedpyright", -- Python: type checking
	"omnisharp", -- c# LSP
	"qmlls", -- QML LSP
	"ts_ls", -- TS/JS LSP
	"texlab", -- Latex LSP
	"matlab-ls", -- Matlab Lsp
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
vim.lsp.config("clangd", {
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "c", "cpp" },
	cmd = { "clangd" },
})

-- PYTHON
vim.lsp.config("ruff", {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	on_attach = function(client, bufnr)
		-- lsp use ruff to formatter
		client.server_capabilities.documentFormattingProvider = false -- enable vim.lsp.buf.format()
		client.server_capabilities.documentRangeFormattingProvider = false -- formatting will be used by conform.nvim
		client.server_capabilities.hoverProvider = false -- use basedpyrigt

		local bufopts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "<C-K>", vim.lsp.buf.signature_help, bufopts)
	end,
	init_options = {
		settings = {
			logLevel = "warn",
			organizeImports = true, -- use code action for organizeImports
			showSyntaxErrors = true, -- show syntax error diagnostics
			codeAction = {
				disableRuleComment = { enable = false }, -- show code action about rule disabling
				fixViolation = { enable = false }, -- show code action for autofix violation
			},
			format = { -- use conform.nvim
				preview = false,
			},
			lint = { -- it links with ruff, but lint.args are different with ruff configuration
				enable = true,
			},
		},
	},
	single_file_support = false,
})

vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
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

		-- texlab supports build / viewer
		-- but viewer doesn't executes inverse search properly
		-- build can only compile current file using %f, not main file.
		-- If you want to compile main file, remove argument %f and use config file like .latexmk or Tectonic.toml
		-- so It needs to use texflow.nvim to more flexible operation.

		-- texlab supports two diagnostics source (texlab / latex)
		-- `texlab` source shows results independent of the compile engine.
		-- `latex` source read log file and show the result of parsing.
		-- It has  not enough feature. because It doesn't find proper line of package warning.
		-- and It cannot show properly when there are multiple files.
		-- and It doesn't reset even though there are no warning in log file.
		-- I cannot understand when the `latex` source parsing and updating.
		-- It is the second reason why I use texflow.nvim
	},
})

-- MATLAB
vim.lsp.config("matlab-ls", {
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
