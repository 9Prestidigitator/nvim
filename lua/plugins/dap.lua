-- DAP
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()
dap.listeners.after.event_initialized.dapui_config = function()
	dapui.open()
	vim.keymap.set("n", "<leader>du", function()
		dapui.open({ reset = true })
	end, { desc = "Reset DAP ui." })
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
	vim.keymap.del("n", "<leader>du")
end

require("dap-python").setup(os.getenv("HOME") .. "/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
dap.configurations.python = {
	{
		name = "Debug python file",
		type = "python",
		request = "launch",
		program = "${file}",
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
					return "/usr/bin/python"
				end
			end
		end,
	},
}

dap.adapters.codelldb = {
	name = "Launch codelldb server",
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}

dap.configurations.cpp = {
	name = "Debug c++ binary",
	type = "codelldb",
	request = "launch",
	program = function()
		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	end,
}

dap.configurations.rust = {
	{
		name = "Debug rust binary",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		end,
	},
}

dap.adapters.coreclr = {
	name = "Launch netcoredbg binary",
	type = "executable",
	command = os.getenv("HOME") .. "/.local/share/nvim/mason/packages/netcoredbg/netcoredbg",
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		name = "Debug c# dll",
		type = "coreclr",
		request = "launch",
		program = function()
			return vim.fn.input("Path to dll", vim.fn.getcwd(), "file")
		end,
	},
}

require("mason-nvim-dap").setup({ automatic_installation = true })
