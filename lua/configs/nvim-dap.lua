local dap = require "dap"
require("dapui").setup()
require("mason-nvim-dap").setup {
  automatic_setup = true,
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      local conda_path = vim.env.CONDA_PREFIX
      if conda_path then
        -- Use conda path if available
        return conda_path .. "/bin/python"
      else
        -- Use the virtualenv if available
        local venv_path = os.getenv "VIRTUAL_ENV"
        if venv_path then
          return venv_path .. "/bin/python"
        else
          return "/usr/bin/python"
        end
      end
    end,
  },
}

local is_juce_proj = vim.fn.glob "*.jucer" ~= ""

local juce_config = {
  name = "Launch JUCE AudioPluginHost",
  type = "codelldb",
  request = "launch",
  program = "~/JUCE/extras/AudioPluginHost/Builds/LinuxMakefile/build/AudioPluginHost",
  args = {},
  runInTerminal = true,
}

local default_cpp = {
  name = "Launch CPP Binary",
  type = "codelldb",
  request = "launch",
  program = function()
    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  end,
}

dap.configurations.cpp = is_juce_proj and { juce_config } or { default_cpp }

dap.adapters.codelldb = {
  name = "codelldb server",
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}

dap.adapters.coreclr = {
  type = "executable",
  command = os.getenv "HOME" .. "/.local/share/nvim/mason/packages/netcoredbg/netcoredbg",
  args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
    end,
  },
}
