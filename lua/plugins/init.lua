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

  -- Notifications
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      require("notify").setup {
        background_colour = "#000000",
      }
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
    config = function()
      require("outline").setup {
        outline_window = {
          width = 14,
        },
      }
    end,
  },

  -- Surround plugin
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  -- neorg: notetaking plugin
  {
    "nvim-neorg/neorg",
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      return require "configs.neorg"
    end,
  },

  -- For markdown links and notetaking
  {
    "lervag/wiki.vim",
    lazy = false, -- This is only needed if you specified lazy to be the
    -- default, see `:help lazy.nvim` and the LAZY LOADING
    -- section.
    init = function()
      return require "configs.wiki-vim"
    end,
  },

  -- Movement animations
  -- This one has an issue: the best animation shown off, left_to_right, does not work.
  -- {
  --   "rachartier/tiny-glimmer.nvim",
  --   event = "VeryLazy",
  --   priority = 10, -- Needs to be a really low priority, to catch others plugins keybindings.
  --   -- opts = {
  --   --   require "configs.tiny-glimmer",
  --   -- },
  --   init = function()
  --     require("configs.tiny-glimmer")
  --   end,
  -- },

  -- Animations
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    enabled = not vim.g.neovide and os.getenv "TERM" ~= "kitty",
    -- enabled = true,
    priority = 10,
    config = function()
      require("smear_cursor").setup {
        legacy_computing_symbols_support = true,
        -- -- trailing_exponent = 0.3,
        -- -- trailing_stiffness = 0.5,
        -- stiffness = 0.5,
        -- -- stiffness = 0.6,
        -- trailing_stiffness = 0.25,
        -- -- trailing_exponent = 0.1,
        -- -- gamma = 1,
        min_horizontal_distance_smear = 4,
        min_vertical_distance_smear = 2,

        -- cursor_color = require("theme").get_colors().text,
        -- transparent_bg_fallback_color = require("theme").get_colors().base,
      }
    end,
  },

  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    version = false,
    config = function()
      return require "configs.mini-animate"
    end,
  },

  -- Database query extension
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  -- Markdown lists
  {
    "lervag/lists.vim", -- lists
    lazy = false,
    init = function()
      return require "configs.lists-vim"
    end,
  },

  -- Markdown previewer
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- For blink.cmp's completion
    -- source
    -- dependencies = {
    --     "saghen/blink.cmp"
    -- },
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
    -- lazy = true,
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      return require "configs.nvim-dap-ui"
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
  },

  -- Testing utility
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
    },
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
        "c_sharp",
        "norg",
      },
    },
  },
}
