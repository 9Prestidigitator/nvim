_G.term_win_id = nil
_G.term_buf_id = nil

function _G.ToggleTerminal()
	if _G.term_win_id and vim.api.nvim_win_is_valid(_G.term_win_id) then
		vim.api.nvim_win_hide(_G.term_win_id)
		_G.term_win_id = nil
	else
		vim.cmd("botright 12split")
		if _G.term_buf_id and vim.api.nvim_buf_is_valid(_G.term_buf_id) then
			vim.api.nvim_win_set_buf(0, _G.term_buf_id)
		else
			vim.cmd("terminal")
			_G.term_buf_id = vim.api.nvim_get_current_buf()
		end
		vim.cmd("startinsert")
		_G.term_win_id = vim.api.nvim_get_current_win()
	end
end
