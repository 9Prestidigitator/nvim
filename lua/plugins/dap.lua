local dap = require("dap")
local dapui = require("dapui")
local env = require("core.env")
local tools = require("core.tools")

dapui.setup()
dap.listeners.after.event_initialized.dapui_config = function()
	dapui.open()
end
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

local codelldb_cmd
if env.is_nix() and os.getenv("CODELLDB_PATH") ~= nil then
	codelldb_cmd = vim.env.CODELLDB_PATH
else
	codelldb_cmd = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
end

dap.adapters.codelldb = {
	name = "Launch codelldb server",
	type = "server",
	port = "${port}",
	executable = {
		command = codelldb_cmd,
		args = { "--port", "${port}" },
	},
}

dap.configurations.c = {
	{
		name = "Debug binary",
		type = "codelldb",
		request = "launch",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = function()
			local path = vim.fn.input("Executable: ", vim.fn.getcwd(), "file")
			if path == "" then
				return nil
			end
			local result = vim.fn.system("cmake --build build")
			if vim.v.shell_error ~= 0 then
				vim.notify(result, vim.log.levels.ERROR)
				return nil
			end
			return path
		end,
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
	},
	{
		name = "Debug binary (skip build)",
		type = "codelldb",
		request = "launch",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = function()
			local path = vim.fn.input("Executable: ", vim.fn.getcwd(), "file")
			if path == "" then
				return nil
			end
            return path
		end,
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
	},
}
dap.configurations.cpp = dap.configurations.c

dap.configurations.rust = {
	{
		name = "Debug Rust binary",
		type = "codelldb",
		request = "launch",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = function()
			local path = vim.fn.input("Executable: ", vim.fn.getcwd(), "file")
			if path == "" then
				return nil
			end
			local result = vim.fn.system("cargo build")
			if vim.v.shell_error ~= 0 then
				vim.notify(result, vim.log.levels.ERROR)
				return nil
			end
			return path
		end,
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
	},
	{
		name = "Debug Rust binary (skip build)",
		type = "codelldb",
		request = "launch",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		program = function()
			local path = vim.fn.input("Executable: ", vim.fn.getcwd(), "file")
			if path == "" then
				return nil
			end
            return path
		end,
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
	},
}

local netcoredbg_cmd
if env.is_nix() then
	netcoredbg_cmd = vim.fn.exepath("netcoredbg")
else
	netcoredbg_cmd = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"
end

dap.adapters.coreclr = {
	name = "Launch netcoredbg binary",
	type = "executable",
	command = netcoredbg_cmd,
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		name = "Debug .NET dll",
		type = "coreclr",
		request = "launch",
		cwd = "${workspaceFolder}",
		program = function()
			local path = vim.fn.input("dll: ", vim.fn.getcwd(), "file")
			if path == "" then
				return nil
			end
			local result = vim.fn.system("dotnet build")
			if vim.v.shell_error ~= 0 then
				vim.notify(result, vim.log.levels.ERROR)
				return nil
			end
			return path
		end,
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
	},
	{
		name = "Debug .NET dll (skip build)",
		type = "coreclr",
		request = "launch",
		cwd = "${workspaceFolder}",
		program = function()
			local path = vim.fn.input("dll: ", vim.fn.getcwd(), "file")
			if path == "" then
				return nil
			end
            return path
		end,
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
	},
}

require("dap-python").setup(vim.fn.exepath("python"))
dap.configurations.python = {
	{
		name = "Debug python file",
		type = "python",
		request = "launch",
		program = "${file}",
		args = function()
			local args_string = vim.fn.input("Arguments: ")
			return vim.fn.split(args_string)
		end,
		pythonPath = function()
			local conda_path = vim.env.CONDA_PREFIX
			if conda_path then
				-- Use conda path if available
				return conda_path .. "/bin/python"
			else
				-- Use the virtualenv if available
				local venv_path = os.getenv("VIRTUAL_ENV")
				if venv_path then
					return venv_path .. "/bin/python"
				else
					return vim.fn.exepath("python")
				end
			end
		end,
	},
}

require("mason-nvim-dap").setup({ automatic_installation = tools.mason_should_manage_tools() })
