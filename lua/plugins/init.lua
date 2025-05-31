return {

  -- Greeter: Alpha
  {
    "goolord/alpha-nvim",
    event = "VimEnter", -- load plugin after all configuration is set
    dependencies = {
      -- "nvim-tree/nvim-web-devicons", -- NOTE: Enable if needed
    },
    init = function()
      return require "configs.alpha"
    end,
  },

  -- Vimtex
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      return require "configs.vimtex"
    end,
  },

  -- repl
  {
    -- "Vigemus/iron.nvim",
    "g0t4/iron.nvim",
    branch = "fix-clear-repl",
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      return require "configs.iron-nvim"
    end,
  },

  -- outline plugin
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle Outline" },
    },
    opts = {
      -- options here
    },
    config = function()
      require("outline").setup {
        outline_window = {
          width = 14,
        },
      }
    end,
  },

  -- Markdown (Notetaking) stuff:
  {
    "lervag/lists.vim", -- lists
    lazy = false,
    init = function()
      vim.g.lists_filetypes = { "markdown" }
      return require "configs.lists-vim"
    end,
  },

  -- Terminal markdown previewer
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- For blink.cmp's completion
    -- source
    -- dependencies = {
    --     "saghen/blink.cmp"
    -- },
  },

  -- Neovim Wiki for markdown links and notetaking
  {
    "lervag/wiki.vim",
    lazy = false, -- This is only needed if you specified lazy to be the
    -- default, see `:help lazy.nvim` and the LAZY LOADING
    -- section.
    init = function()
      return require "configs.wiki-vim"
    end,
  },

  -- neorg
  {
    "nvim-neorg/neorg",
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = true,
  },

  -- Save and Load buffers automatically for each directory
  {
    "rmagatti/auto-session",
    lazy = false,
    --enables autocomplete for opts
    --@module "auto-session"
    --@type AutoSession.Config
    opts = require "configs.auto-session",
  },

  -- Debugger stuff
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = { "nvim-neotest/nvim-nio" },
    config = function()
      return require "configs.nvim-dap-ui"
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
  },

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
    end,
  },

  -- Debugger
  {
    "mfussenegger/nvim-dap",
    config = function()
      return require "configs.nvim-dap"
    end,
  },

  -- LSP Stuff
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
    ft = { "python" },
    opts = function()
      return require "configs.none-ls"
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = function()
      return require "configs.mason"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "cpp",
        "c",
        "luadoc",
        "printf",
      },
    },
  },
}
