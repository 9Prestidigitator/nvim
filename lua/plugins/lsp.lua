require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls", -- bash LSP
		"lua_ls", -- lua LSP
		"rust_analyzer", -- rust LSP
		"clangd", -- c/c++ LSP
		"ruff", -- Python: Code actions, formatting
		"basedpyright", -- Python: type checking
		"pyrefly", -- Python: autocompletion
		"omnisharp", -- C# LSP
        "qmlls", -- QML LSP
        "ts_ls", -- TS/JS LSP
        "texlab", -- Latex LSP
        "matlab_ls", -- Matlab LSP
	},
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
	"pyrefly", -- Python: autocompletion
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
})

-- PYTHON
local root_dir_ruff = function(bufnr, cb)
	local root = vim.fs.root(bufnr, {
		"pyproject.toml",
		"ruff.toml",
		".ruff.toml",
		".git",
	}) or vim.fn.expand("%:p:h")
	cb(root)
end
vim.lsp.config("ruff", {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_dir = root_dir_ruff,
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

local root_dir_basedpyright = function(bufnr, cb)
	local root = vim.fs.root(bufnr, {
		"pyproject.toml",
		"pyrightconfig.json",
		".git",
	}) or vim.fn.expand("%:p:h")
	cb(root)
end
vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_dir = root_dir_basedpyright,
	on_attach = function(client, _)
		client.server_capabilities.completionProvider = false -- use pyrefly for fast response
		client.server_capabilities.definitionProvider = false -- use pyrefly for fast response
		client.server_capabilities.documentHighlightProvider = false -- use pyrefly for fast response
		client.server_capabilities.renameProvider = false -- use pyrefly as I think it is stable
		client.server_capabilities.semanticTokensProvider = false -- use pyrefly it is more rich
	end,
	settings = { -- see https://docs.basedpyright.com/latest/configuration/language-server-settings/
		basedpyright = {
			disableOrganizeImports = true, -- use ruff instead of it
			analysis = {
				autoImportCompletions = true,
				autoSearchPaths = true, -- auto serach command paths like 'src'
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
})

local pid = {
	pyrefly = {},
}
local root_dir_pyrefly = function(bufnr, cb)
	local root = vim.fs.root(bufnr, {
		"pyproject.toml",
		"pyrefly.roml",
		".git",
	}) or vim.fn.expand("%:p:h")
	cb(root)
end
vim.lsp.config("pyrefly", {
	cmd = { "pyrefly", "lsp" },
	filetypes = { "python" },
	root_dir = root_dir_pyrefly,
	on_attach = function(client, _)
		client.server_capabilities.codeActionProvider = false -- basedpyright has more kinds
		client.server_capabilities.documentSymbolProvider = false -- basedpyright has more kinds
		client.server_capabilities.hoverProvider = false -- basedpyright has more kinds
		client.server_capabilities.inlayHintProvider = false -- basedpyright has more kinds
		client.server_capabilities.referenceProvider = false -- basedpyright has more kinds
		client.server_capabilities.signatureHelpProvider = false -- basedpyright has more kinds

		if vim.g.has_win32 then
			local processname = "pyrefly.exe"
			if not processname then
				return nil
			end

			-- get process list using cmd prompt (wmic is faster than pwsh)
			local command = {
				"wmic",
				"process",
				"where",
				"name=" .. '"' .. processname .. '"',
				"get",
				"CreationDate,ProcessId",
				"/format:csv",
			}
			local result = vim.system(command):wait() -- stdout, stderr, ret
			if result.code ~= 0 then
				vim.print("wmic command failed:", result.stderr)
				return nil
			end

			-- split fields
			local processes = {}
			for line in result.stdout:gmatch("[^\r\n]+") do
				if not (line:match("^Node") or line:match("^$")) then -- ignore header / empty line
					-- CSV: Node,CreationDate,ProcessId
					local fields = vim.split(line, ",")
					if fields then
						table.insert(processes, { creation = fields[2], pid = fields[3] })
					end
				end
			end

			-- sort by creation time to check what is recent one
			table.sort(processes, function(a, b)
				return a.creation > b.creation
			end)

			return processes[1].pid
		end
	end,
	on_exit = function()
		if vim.g.has_win32 then
			for id in ipairs(pid.pyrefly) do
				if not id then
					return nil
				end

				local command = { "taskkill", "/PID", tostring(id), "/F" }
				local result = vim.system(command):wait() -- stdout, stderr, ret
				if result.code ~= 0 then
					return nil
				end
			end
		end
	end,
	settings = {},
})

-- C#
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
