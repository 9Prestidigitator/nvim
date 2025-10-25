local cursorline_exclude = { "alpha", "TelescopePrompt", "oil" }
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, { -- Disable in inactive windows
	group = cursorline_group,
	callback = function()
		local ft = vim.bo.filetype
		local excluded = vim.tbl_contains(cursorline_exclude, ft)
		if excluded then
			vim.opt_local.cursorline = false
		else
			vim.opt_local.cursorline = true
		end
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = cursorline_group,
	callback = function()
		vim.opt_local.cursorline = false
	end,
})
