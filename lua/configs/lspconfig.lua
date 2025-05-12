require("nvchad.configs.lspconfig").defaults()

local config = require "nvchad.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local lspconfig = require "lspconfig"

lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "c", "cpp" },
}

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

-- require('lspconfig').ruff.setup({
--   init_options = {
--     settings = {
--       logLevel = 'info',
--     }
--   }
-- })

local servers = { "html", "cssls" }
vim.lsp.enable(servers)
