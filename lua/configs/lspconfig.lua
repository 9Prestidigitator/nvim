require("nvchad.configs.lspconfig").defaults()

local config = require "nvchad.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local lspconfig = require "lspconfig"

-- C/C++
lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "c", "cpp" },
}

-- Python
lspconfig.pyright.setup {
  before_init = function(_, config)
    -- Detect virtualenv automatically
    local venv = os.getenv "VIRTUAL_ENV"
    if venv then
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = venv .. "/bin/python"
    end
  end,
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    -- pyright = {
    --   disableOrganizeImports = false,
    -- },
    -- python = {
    --   analysis = {
    --     ignore = { "*" },
    --   },
    -- },
  },
  filetypes = { "python" },
}

-- C#
lspconfig.omnisharp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "dotnet",
    os.getenv "HOME" .. "/.local/share/nvim/mason/packages/omnisharp/OmniSharp.dll",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
  },
  -- Enables support for reading code style, naming convention and analyzer
  -- settings from .editorconfig.
  enable_editorconfig_support = true,
  -- If true, MSBuild project system will only load projects for files that
  -- were opened in the editor. This setting is useful for big C# codebases
  -- and allows for faster initialization of code navigation features only
  -- for projects that are relevant to code that is being edited. With this
  -- setting enabled OmniSharp may load fewer projects and may thus display
  -- incomplete reference lists for symbols.
  enable_ms_build_load_projects_on_demand = false,
  -- Enables support for roslyn analyzers, code fixes and rulesets.
  enable_roslyn_analyzers = false,
  -- Specifies whether 'using' directives should be grouped and sorted during
  -- document formatting.
  organize_imports_on_format = true,
  -- Enables support for showing unimported types and unimported extension
  -- methods in completion lists. When committed, the appropriate using
  -- directive will be added at the top of the current file. This option can
  -- have a negative impact on initial completion responsiveness,
  -- particularly for the first few completion sessions after opening a
  -- solution.
  enable_import_completion = true,
  -- Specifies whether to include preview versions of the .NET SDK when
  -- determining which version to use for project loading.
  sdk_include_prereleases = true,
  -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
  -- true
  analyze_open_documents_only = false,
}

-- Matlab
lspconfig.matlab_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Rust
-- require('lspconfig').ruff.setup({
--   init_options = {
--     settings = {
--       logLevel = 'info',
--     }
--   }
-- })

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

