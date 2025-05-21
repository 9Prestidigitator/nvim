local alpha = require "alpha"
local dashboard = require "alpha.themes.dashboard"

local header = {
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                     ]],
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
}

dashboard.section.header.val = header

dashboard.section.buttons.val = {
  dashboard.button("e", "   File explorer", ":NvimTreeToggle <CR>"),
  dashboard.button("f", "   Find file", ":Telescope find_files previewer=false<CR>"),
  dashboard.button("w", "󰱼   Find word", ":Telescope live_grep<CR>"),
  dashboard.button("r", "   Recent", ":Telescope oldfiles<CR>"),
  dashboard.button("d", "   Change Directory", ":CdAndRestore<CR>"),
  dashboard.button("i", "󰈙   Wiki", ":WikiIndex<CR>"),
  dashboard.button("c", "   Config", ":cd ~/.config/nvim | SessionRestore<CR>"),
  -- dashboard.button("c", "   Config", "e $MYVIMRC <CR>"),
  dashboard.button("l", "󰒲   Lazy", ":Lazy<CR>"),
  dashboard.button("m", "󱌣   Mason", ":Mason<CR>"),
  dashboard.button("q", "   Quit NVIM", ":qa<CR>"),
}

-- set highlight groups
vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#ffffff" })
dashboard.section.header.opts.hl = "DashboardHeader"

vim.api.nvim_set_hl(0, "DashboardFooterNormal", { fg = "#ffffff" }) -- White (default)
vim.api.nvim_set_hl(0, "DashboardFooterOrange", { fg = "#ffa500" }) -- Orange for > 50ms
vim.api.nvim_set_hl(0, "DashboardFooterRed", { fg = "#D9534F" }) -- Red for > 60ms

vim.api.nvim_set_hl(0, "DashboardButtonKey", { fg = "#ffffff", bold = true }) -- Key color
vim.api.nvim_set_hl(0, "DashboardButtonText", { fg = "#ffffff" }) -- text color

for _, button in ipairs(dashboard.section.buttons.val) do
  button.opts.hl_shortcut = "DashboardButtonKey" -- Apply to key (e.g., "e", "f")
  button.opts.hl = "DashboardButtonText" -- Apply to the text (e.g., "File explorer")
end

dashboard.opts.opts.noautocmd = true -- This prevents any unwanted autocommands (e.g., BufRead, BufEnter)

alpha.setup(dashboard.opts) -- setup

vim.api.nvim_create_autocmd("User", { -- Measure start up time
  pattern = "LazyVimStarted",
  callback = function()
    local plugins = require("lazy").stats()
    local time = (math.floor(plugins.startuptime * 100) / 100)
    local footer_hl = "DashboardFooterNormal" -- Default white

    if time > 60 then
      footer_hl = "DashboardFooterRed" -- Red if > 60ms
    elseif time > 50 then
      footer_hl = "DashboardFooterOrange" -- Orange if > 50ms
    end

    dashboard.section.footer.opts.hl = footer_hl

    dashboard.section.footer.val = {
      " ",
      " ",
      " ",
      "󱐌 " .. plugins.count .. " plugins loaded in " .. time .. " ms",
    }
    pcall(vim.cmd.AlphaRedraw)
  end,
})
