require "nvchad.mappings"

-- add yours here
local map = vim.keymap.set
-- These are some silly ones, rarely useful
-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Go to alpha
map("n", "<leader>a", "<cmd> Alpha | NvimTreeClose <cr>", { desc = " ALPHA" })

map("n", "<leader>A", function()
  local var = vim.g.minianimate_disable
  if var == true then
    vim.g.minianimate_disable = false
  else
    vim.g.minianimate_disable = true
  end
end, { desc = "Toggle Animations" })

-- DAP Debugging commands
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <cr>", { desc = "Add breakpoint at line" })
map("n", "<leader>dq", "<cmd> DapClearBreakpoints <cr>", { desc = "Clear all Breakpoints" })
map("n", "<leader>dr", "<cmd> DapContinue <cr>", { desc = "Start or continue the debugger" })
map("n", "<leader>dl", "<cmd> DapStepOver <cr>", { desc = "Debugger: Step over" })
map("n", "<leader>dk", "<cmd> DapStepOut <cr>", { desc = "Debugger: Step Out" })
map("n", "<leader>dj", "<cmd> DapStepInto <cr>", { desc = "Debugger: Step Into" })
map("n", "<leader>dc", function()
  require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "Add conditional breakpoint" })
map("n", "<leader>dx", function()
  require("dap").terminate()
  require("dap").disconnect()
end, { desc = "Debugger: Quit" })
-- DAP Python debugging commands
map("n", "<leader>dpr", function()
  require("dap-python").test_method()
end, { desc = "Debug Python method" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Error navigation
map("n", "gen", function()
  vim.diagnostic.goto_next()
end, { desc = "Go to next error." })
map("n", "gep", function()
  vim.diagnostic.goto_prev()
end, { desc = "Go to previous  error." })

-- buffer navigation
map("n", "gbl", function()
  require("nvchad.tabufline").move_buf(1)
end, { desc = "Move current tab to the right" })
map("n", "gbh", function()
  require("nvchad.tabufline").move_buf(-1)
end, { desc = "Move current tab to the left" })

-- tab navigation
map("n", "gtn", "<cmd> tabnext <cr>", { desc = "Go to next tab" })
map("n", "gtp", "<cmd> tabprevious <cr>", { desc = "Go to previous tab" })
map("n", "gtc", "<cmd> tabnew <cr>", { desc = "Create new tab" })
