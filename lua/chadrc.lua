-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  transparency = true,

  -- Debugger Customization
  vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DapBreakpoint",
    linehl = "",
    numhl = "",
  }),
  vim.fn.sign_define("DapBreakpointCondition", {
    text = "",
    texthl = "DapBreakpointCondition",
    linehl = "",
    numhl = "",
  }),
  vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DapStopped",
    linehl = "",
    numhl = "",
  }),
  vim.api.nvim_set_hl(0, "DapBreakpoint", {
    fg = "#f38ba8", -- light red (Catppuccin pink)
    bg = "NONE",
    bold = true,
  }),
  vim.api.nvim_set_hl(0, "DapBreakpointCondition", {
    fg = "#f38ba8", -- light red (Catppuccin pink)
    bg = "NONE",
    bold = true,
  }),
  vim.api.nvim_set_hl(0, "DapStopped", {
    fg = "#f9e3e4",
    bg = "NONE",
  }),

  -- Upper and lower relative line number colors
  vim.api.nvim_set_hl(0, "LineNrAbove", {
    fg = "#51B3EC",
    bold = false,
  }),
  vim.api.nvim_set_hl(0, "LineNrBelow", {
    fg = "#FB508F",
    bold = false,
  }),

  hl_override = {
    -- Change Window Separator color
    WinSeparator = {
      fg = "#6C6F7A",
    },
    -- NvimTree (file explorer) colors
    NvimTreeIndentMarker = {
      fg = "#7f849c",
    },
    NvimTreeFolderArrowClosed = {
      fg = "#7f849c",
    },
    NvimTreeFolderArrowOpen = {
      fg = "#cdd6f4",
    },
    NeoTreeIndentMarker = {
      fg = "#7f849c",
    },
    NeoTreeFolderArrowClosed = {
      fg = "#7f849c",
    },
    NeoTreeFolderArrowOpen = {
      fg = "#cdd6f4",
    },
    -- Change main line number colors
    CursorLineNr = {
      fg = "#e8f6f8",
      bold = true,
    },
    -- Comment formatting
    ["@comment"] = {
      italic = true,
      fg = "#a6adc8",
    },
    Comment = {
      italic = true,
      fg = "#a6adc8",
    },
    Visual = {
      fg = "#383c4a",
      bg = "#e8f6f8",
    },
  },
}

M.mason = {
  -- Put all non formatting Mason packages here!
  pkgs = {
    "clangd",
    "codelldb",
    "cpptools",
    "pyright",
    "mypy",
    "ruff",
    "debugpy",
    "csharp-language-server",
    "csharpier",
    "omnisharp",
    "netcoredbg"
  },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
