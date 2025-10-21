-- [[
-- OPTIONS
-- ]]

vim.o.backup = false      -- Don't create backup files
vim.o.writebackup = false -- Don't create backup before writing
vim.o.undofile = true
vim.o.swapfile = false
vim.o.showmode = false

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true
vim.o.scrolloff = 2
vim.o.sidescrolloff = 6
vim.o.cursorline = true
local cursorline_exclude = { "alpha", "TelescopePrompt" }
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, { -- Disable in inactive windows
    group = cursorline_group,
    callback = function()
        local ft = vim.bo.filetype
        local excluded = vim.tbl_contains(cursorline_exclude, ft)
        if not excluded and vim.bo.filetype ~= "" then
            vim.opt_local.cursorline = true
        end
    end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    callback = function()
        vim.opt_local.cursorline = false
    end,
})
vim.o.fillchars = 'eob: '

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = false

vim.o.termguicolors = true
vim.o.winborder = "rounded"
vim.o.signcolumn = "yes"

vim.o.laststatus = 3
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = vim.g.vscode and 1000 or 300

-- [[
-- GLOBALS
-- ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_banner = 0 -- toggle with I
vim.g.netrw_sizestyle = "H"
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_localcopydircmd = "cp -r"
vim.g.netrw_preview = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_fastbrowse = 0

-- [[
-- PLUGINS
-- ]]

vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },          -- LSPs
    { src = "https://github.com/mason-org/mason.nvim" },           -- Loads LSP's, DAP's, linters, and formatters
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" }, -- Autoloads LSP's for Mason

    { src = "https://github.com/stevearc/conform.nvim" },          -- Formatter
    { src = "https://github.com/zapling/mason-conform.nvim" },     -- Autoloads formatters for Mason

    { src = "https://github.com/mfussenegger/nvim-dap" },          -- DAP for Debugging
    { src = "https://github.com/jay-babu/mason-nvim-dap.nvim" },   -- DAP Mason integration
    { src = "https://github.com/rcarriga/nvim-dap-ui" },           -- DAP UI
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/mfussenegger/nvim-dap-python" },

    { src = "https://github.com/vague2k/vague.nvim" },        -- Theme
    { src = "https://github.com/sphamba/smear-cursor.nvim" }, --Animated Cursor

    { src = "https://github.com/rmagatti/auto-session" },     -- Saves sessions by directory
    { src = "https://github.com/nvim-mini/mini.pick" },       -- might replace with telescope, need to do some reading
    { src = "https://github.com/nvim-mini/mini.icons" },      -- Icons
    { src = "https://github.com/kylechui/nvim-surround" },    -- Surround plugin
    { src = "https://github.com/folke/lazydev.nvim" },        -- Makes lua development much better
    { src = "https://github.com/folke/which-key.nvim" },      -- Because I'm a n00b
    { src = "https://github.com/windwp/nvim-autopairs" },     -- Saves a lot of time
    { src = "https://github.com/stevearc/oil.nvim" },         -- File Explorer
    { src = "https://github.com/goolord/alpha-nvim" },
    { src = "https://github.com/kdheepak/lazygit.nvim" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

require("mini.pick").setup({
    mappings = {
        toggle_info    = '<C-k>',
        toggle_preview = '<C-p>',
        move_down      = '<Tab>',
        move_up        = '<S-Tab>',
    }
})
vim.api.nvim_create_user_command('PickRecentFiles', function()
    local pick = require('mini.pick')
    local icons = require('mini.icons')
    local oldfiles = vim.v.oldfiles or {}
    local files = vim.tbl_filter(function(f)
        return vim.fn.filereadable(f) == 1 -- Filter only readable files
    end, oldfiles)
    local items = vim.tbl_map(function(path)
        local ext = vim.fn.fnamemodify(path, ':e')
        local icon, _ = icons.get('file', vim.fn.fnamemodify(path, ':t'))
        return string.format('%s %s', icon or ' ', path)
    end, files)
    pick.start({
        source = {
            name = 'Recent Files',
            items = items,
            choose = function(item)
                local path = item:match('^.-%s+(.*)$')
                vim.schedule(function()
                    vim.cmd('edit ' .. vim.fn.fnameescape(path))
                end)
            end,
        },
    })
end, {})

local dashboard = require("alpha.themes.dashboard")
local logo = [[


   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆
    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦
          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄
           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄
          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀
   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄
  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄
 ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄
 ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄
      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆
       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃
]]
dashboard.section.header.val = vim.split(logo, "\n")
dashboard.section.buttons.val = {
    dashboard.button("n", " " .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
    dashboard.button("r", " " .. " Recent files", [[<cmd>PickRecentFiles<cr>]]),
    dashboard.button("d", " " .. " Recent Sessions", [[<cmd>AutoSession search<cr>]]),
    dashboard.button("g", " " .. " Find text", [[<cmd>Pick grep_live<cr>]]),
    dashboard.button("f", " " .. " Find file", "<cmd>Pick files<cr>"),
    dashboard.button("e", " " .. " File explorer", ":Oil<CR>"),
    dashboard.button("c", " " .. " Config", "<cmd>cd ~/.config/nvim | AutoSession restore<cr>"),
    dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
}
dashboard.opts.cursorline = false
require("alpha").setup(dashboard.opts)
require("lualine").setup({
    theme = "nord",
    options = {
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { 'mode' },
    }
})
require("gitsigns").setup()
require("smear_cursor").setup()
require("smear_cursor").enabled = true
require("vague").setup({ transparent = true })
require("nvim-surround").setup()
require("mason").setup()
require("lazydev").setup()
require("nvim-autopairs").setup()
require("mini.icons").setup()
require("auto-session").setup({
    auto_session_suppress_dirs = {
        "~/",
        "~/Documents",
        "~/Downloads",
    }
})
require("oil").setup(
    {
        default_file_explorer = true,
        keymaps = {
            ["<leader>e"] = { "actions.close", mode = "n" },
        }
    }
)
require("which-key").setup({
    preset = "helix",
    spec = {
        {
            mode = { "n", "x" },
            { "<leader>",  group = "Leader" },
            { "<leader>d", group = "Debug" },
            { "<leader>f", group = "Find" },
            { "<leader>l", group = "LSP" },
            { "<leader>b", group = "Buffer" },
            { "[",         group = "prev" },
            { "]",         group = "next" },
            { "g",         group = "goto" },
            { "ys",        group = "surround" },
            { "z",         group = "fold" },
        },
    },
})

-- [[
-- KEYMAPS
-- ]]

local map = vim.keymap.set
map("n", "<A-h>", "<C-w>h", { silent = true })
map("n", "<A-l>", "<C-w>l", { silent = true })
map("n", "<A-j>", "<C-w>j", { silent = true })
map("n", "<A-k>", "<C-w>k", { silent = true })

map("n", "<C-j>", ":m .+1<CR>==", { desc = "Move line down.", silent = true })
map("n", "<C-k>", ":m .-2<CR>==", { desc = "Move line up.", silent = true })
map("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down." })
map("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up." })

map("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Explorer" })
map("n", "<leader>A", "<CMD>Alpha<CR>", { desc = "Home" })
map("n", "<leader>fg", ":Pick grep_live<CR>", { desc = "Find via ripgrep." })
map("n", "<leader>ff", ":Pick files<CR>", { desc = "Find file in directory." })
map("n", "<leader>fb", ":Pick buffers<CR>", { desc = "Find buffers in session." })
map("n", "<leader>fr", ":PickRecentFiles<CR>", { desc = "Find recent files." })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename (LSP)." })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format current file." })
map("n", "<leader>lg", ":LazyGit<CR>", { desc = "Lazygit" })
map("n", "<leader>bw", ":bw<CR>", { desc = "Delete Buffer." })
map("n", "<leader>bb", ":buffers!<CR>", { desc = "Show all buffers." })

map({ "n" }, "<leader>/", 'gcc', { desc = "Comment", silent = true })
map({ "n" }, "<Esc>", "<CMD>noh<CR>", { silent = true })
map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard." })
map("n", "<C-s>", "<CMD>w<CR>", { desc = "Save (write) file." })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save (write) file." })
map("v", "<", "<gv", { desc = "Indent left and reselect." })
map("v", ">", ">gv", { desc = "Indent right and reselect." })
-- DAP Debugging commands
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <cr>", { desc = "Add breakpoint at line" })
map("n", "<leader>dq", "<cmd> DapClearBreakpoints <cr>", { desc = "Clear all Breakpoints" })
map("n", "<leader>dr", "<cmd> DapContinue <cr>", { desc = "Start or continue the debugger" })
map("n", "<leader>dl", "<cmd> DapStepOver <cr>", { desc = "Debugger: Step over" })
map("n", "<leader>dk", "<cmd> DapStepOut <cr>", { desc = "Debugger: Step Out" })
map("n", "<leader>dj", "<cmd> DapStepInto <cr>", { desc = "Debugger: Step Into" })
map("n", "<leader>dc", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Add conditional breakpoint" })
map("n", "<leader>dx", function()
    require("dap").terminate()
    require("dap").disconnect()
end, { desc = "Debugger: Quit" })
-- DAP Python debugging commands
map("n", "<leader>dpr", function()
    require("dap-python").test_method()
end, { desc = "Debug Python method" })

_G.term_win_id = nil         -- Store the window ID in a global variable to track it
function _G.ToggleTerminal() -- This is the main function to toggle the terminal
    -- Check if the stored window ID is still valid
    if _G.term_win_id and vim.api.nvim_win_is_valid(_G.term_win_id) then
        -- If it is, hide the window and clear our variable
        vim.api.nvim_win_hide(_G.term_win_id)
        _G.term_win_id = nil
    else
        -- If not, create a new terminal
        vim.cmd('botright 10split') -- Open a 10-line split at the bottom
        vim.cmd('terminal')         -- Start a terminal in that new split
        vim.cmd('startinsert')      -- Enter terminal-insert mode immediately
        -- Store the new window's ID
        _G.term_win_id = vim.api.nvim_get_current_win()
    end
end

vim.api.nvim_create_autocmd('TermOpen', { -- Setup keymaps inside the terminal
    pattern = '*',
    callback = function(ctx)
        -- This is what you asked for:
        -- Map <Esc> to exit terminal-insert mode and go to terminal-normal mode
        -- { buffer = true } makes this map only apply to this terminal buffer
        vim.keymap.set('t', '<C-x>', '<C-\\><C-n>', { buffer = ctx.buf, silent = true, desc = "Exit terminal mode" })
        -- Optional: Also allow toggling *from* the terminal
        -- This map exits terminal mode, then calls the toggle function to close it
        vim.keymap.set('t', '<C-t>', '<C-\\><C-n><Cmd>lua _G.ToggleTerminal()<CR>',
            { buffer = ctx.buf, silent = true, desc = "Toggle terminal" })
    end,
})

-- Map a key in NORMAL mode to open/close the terminal
vim.keymap.set('n', '<leader>t', _G.ToggleTerminal, { desc = "Toggle terminal" })

-- [[
-- Language Features
-- ]]

-- Formatters
require("conform").setup({
    formatters_by_ft = {
        bash = { "shfmt" },
        lua = { "stylua" },
        python = { "black" },
        cs = { "clang-format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        javascript = { "prettier" },
    },
})
require("mason-conform").setup()

-- Might add linters later however LSPs will do for now

-- LSP's
local lsps = {
    "lua_ls",    -- lua LSP
    "bashls",    -- bash LSP
    "pyright",   -- Python LSP
    "clangd",    -- c/c++ LSP
    "omnisharp", -- c# LSP
    "bacon_ls",  -- rust LSP
}
require("mason-lspconfig").setup({
    ensure_installed = lsps,
    automatic_installation = true,
})
vim.lsp.enable(lsps)
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
        },
    },
})
vim.lsp.config("omnisharp", {
    cmd = {
        "dotnet",
        os.getenv("HOME") .. "/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll",
        "--languageserver",
        "--hostPID",
        tostring(vim.fn.getpid()),
    },
    enable_editorconfig_support = true,
    enable_ms_build_load_projects_on_demand = false,
    enable_roslyn_analyzers = false,
    organize_imports_on_format = true,
    enable_import_completion = true,
    sdk_include_prereleases = true,
    analyze_open_documents_only = false,
    filetypes = { "cs" },
})

-- DAP
local dap = require("dap")
local dapui = require("dapui")
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

require("mason-nvim-dap").setup({
    ensure_installed = { "netcoredbg", "debugpy", "codelldb" },
    automatic_installation = true,
})

-- [[
-- LOOK
-- ]]

vim.cmd("colorscheme vague")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#5F8499", bold = false }) -- #51B3EC
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#E388A9", bold = false }) -- #FB508F
vim.api.nvim_set_hl(0, "LineNr", { fg = "#D9D9D9", bold = true })
vim.api.nvim_set_hl(0, "Visual", { fg = "#383c4a", bg = "#BBC5C7", bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#8D95B3" })
-- Debugger Customization
vim.fn.sign_define("DapBreakpoint",
    {
        text = "●",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
    })
vim.fn.sign_define("DapBreakpointCondition",
    {
        text = "",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = ""
    })
vim.fn.sign_define("DapStopped",
    {
        text = "",
        texthl = "DapStopped",
        linehl = "",
        numhl = ""
    })
vim.api.nvim_set_hl(0, "DapBreakpoint",
    {
        fg = "#f38ba8",
        bg = "NONE",
        bold = true
    })
vim.api.nvim_set_hl(0, "DapBreakpointCondition",
    {
        fg = "#f38ba8",
        bg = "NONE",
        bold = true
    })
vim.api.nvim_set_hl(0, "DapStopped",
    {
        fg = "#f9e3e4",
        bg = "NONE"
    })
