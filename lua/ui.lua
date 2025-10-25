
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

