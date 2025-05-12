local null_ls = require "null-ls"

local function venv_selector(package)
  local venv = os.getenv "VIRTUAL_ENV"
  if venv and vim.fn.executable(venv .. "/bin/" .. package) == 1 then
    return venv .. "/bin/" .. package
  else
    return package
  end
end

local options = {
  sources = {
    null_ls.builtins.formatting.black,

    null_ls.builtins.diagnostics.mypy.with {
      command = venv_selector "mypy",
      extra_args = { "--ignore-missing-imports" },
    },

    -- require("none-ls.diagnostics.ruff").with {
    --   command = venv_selector "ruff",
    -- },
  },
}

return options
