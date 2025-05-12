-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  transparency = true,

  -- Customize Breakpoint
  vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DapBreakpoint",
    linehl = "",
    numhl = "",
  }),
  vim.api.nvim_set_hl(0, "DapBreakpoint", {
    fg = "#f38ba8", -- light red (Catppuccin pink)
    bg = "NONE",
    bold = true,
  }),
  vim.api.nvim_set_hl(0, "LineNrAbove", {
      fg = "#51B3EC",
      bold = false,
  }),
  vim.api.nvim_set_hl(0, "LineNrBelow", {
      fg = "#FB508F",
      bold = false,
  }),

  hl_override = {
    -- Lighten inactive tabs
    -- TabLine = {
    --   fg = "#7f849c", -- a light greyish color
    --   bg = "NONE",
    -- },
    -- TabLineFill = {
    --   fg = "#7f849c",
    --   bg = "NONE",
    -- },
    TabLineSel = {
      fg = "#cdd6f4",
      bg = "NONE",
      bold = true,
    },
    -- Lighten nvimtree / neo-tree collapsed arrows
    NvimTreeIndentMarker = {
      fg = "#7f849c",
    },
    NeoTreeIndentMarker = {
      fg = "#7f849c",
    },
    NvimTreeFolderArrowClosed = {
      fg = "#7f849c",
    },
    NvimTreeFolderArrowOpen = {
      fg = "#cdd6f4",
    },
    NeoTreeFolderArrowClosed = {
      fg = "#7f849c",
    },
    NeoTreeFolderArrowOpen = {
      fg = "#cdd6f4",
    },
    -- Change line number colors
    CursorLineNr = {
      fg = "#f5e0dc",
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
  },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
