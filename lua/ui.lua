vim.cmd("colorscheme vague")

vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#5F8499", bold = false }) -- #51B3EC
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#E388A9", bold = false }) -- #FB508F
vim.api.nvim_set_hl(0, "LineNr", { fg = "#D9D9D9", bold = true })
vim.api.nvim_set_hl(0, "Visual", { fg = "#383c4a", bg = "#BBC5C7", bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#8D95B3" })

-- Debugger Customization
vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DapBreakpoint",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
	text = "",
	texthl = "DapBreakpointCondition",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapStopped", {
	text = "",
	texthl = "DapStopped",
	linehl = "",
	numhl = "",
})

vim.api.nvim_set_hl(0, "DapBreakpoint", {
	fg = "#f38ba8",
	bg = "NONE",
	bold = true,
})

vim.api.nvim_set_hl(0, "DapBreakpointCondition", {
	fg = "#f38ba8",
	bg = "NONE",
	bold = true,
})

vim.api.nvim_set_hl(0, "DapStopped", {
	fg = "#f9e3e4",
	bg = "NONE",
})

require("vim._core.ui2").enable({
	enable = true, -- Whether to enable or disable the UI.
	msg = { -- Options related to the message module.
		---@type 'cmd'|'msg' Default message target, either in the
		---cmdline or in a separate ephemeral message window.
		---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
		---or table mapping |ui-messages| kinds and triggers to a target.
		targets = "cmd",
		cmd = { -- Options related to messages in the cmdline window.
			height = 0.5, -- Maximum height while expanded for messages beyond 'cmdheight'.
		},
		dialog = { -- Options related to dialog window.
			height = 0.5, -- Maximum height.
		},
		msg = { -- Options related to msg window.
			height = 0.5, -- Maximum height.
			timeout = 4000, -- Time a message is visible in the message window.
		},
		pager = { -- Options related to message window.
			height = 1, -- Maximum height.
		},
	},
})
