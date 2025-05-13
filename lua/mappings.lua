require "nvchad.mappings"

-- add yours here
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Debugging commands
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <cr>", { desc = "Add breakpoint at line" })
map("n", "<leader>dq", "<cmd> DapClearBreakpoints <cr>", { desc = "Clear all Breakpoints" })
map("n", "<leader>dr", "<cmd> DapContinue <cr>", { desc = "Start or continue the debugger" })
map("n", "<leader>dl", "<cmd> DapStepOver <cr>", { desc = "Debugger: Step over" })
map("n", "<leader>dk", "<cmd> DapStepOut <cr>", { desc = "Debugger: Step Out" })
map("n", "<leader>dj", "<cmd> DapStepInto <cr>", { desc = "Debugger: Step Into" })
map("n", "<leader>dc", function()
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "Add conditional breakpoint" })
map("n", "<leader>dx", function()
  require('dap').terminate()
  require('dap').disconnect()
end, { desc = "Debugger: Quit" })

-- Python debugging commands
map("n", "<leader>dpr", function()
  require("dap-python").test_method()
end, { desc = "Debug Python method" })

-- Run Python Script
local python_term_bufnr = nil
map("n", "<leader>rr", function()
  local file = vim.fn.expand "%:p"
  local name = vim.fn.expand "%"
  local venv = os.getenv "VIRTUAL_ENV"

  if not name:match("%.py") then
    vim.notify("Not a python file!", vim.log.levels.ERROR)
    return
  end

  -- If no terminal exists yet, open one
  if not (python_term_bufnr and vim.api.nvim_buf_is_valid(python_term_bufnr)) then
    vim.cmd "botright split | resize 15 | terminal"
    python_term_bufnr = vim.api.nvim_get_current_buf()
    python_term_chanid = vim.b.terminal_job_id -- Store the terminal's channel ID!
  end

  -- Safety check: make sure channel ID is valid
  if not python_term_chanid then
    vim.notify("No terminal job available!", vim.log.levels.ERROR)
    return
  end

  -- Build the command to run
  local cmd
  if venv then
    cmd = "source " .. venv .. "/bin/activate && python " .. file .. "\n"
  else
    cmd = "python " .. file .. "\n"
  end

  -- Send the command into the stored terminal channel
  vim.fn.chansend(python_term_chanid, cmd)

  -- Return to normal mode
  vim.cmd "stopinsert"
end, { desc = "Run focused Python script" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
