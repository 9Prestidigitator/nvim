local float_win = require("core.float_win")

local M = {}

local state = {
	buf = nil,
	win = nil,
	layout = "bottom",
}

local config = {
	split = {
		width = 24,
		height = 12,
	},
	float = {
		width = 0.88,
		height = 0.80,
		border = "rounded",
		title = " terminal ",
		title_pos = "center",
		zindex = 50,
		close_on_leave = true,
	},
}

local augroup = vim.api.nvim_create_augroup("PopupTerminal", { clear = true })

local valid_win = float_win.valid_win
local valid_buf = float_win.valid_buf

local function visible_terminal_win()
	return float_win.visible_win_for_buf(state.buf)
end

function M.is_open()
	return valid_win(visible_terminal_win() or state.win)
end

local function terminal_is_alive(buf)
	if not valid_buf(buf) then
		return false
	end

	local job_id = vim.b[buf].terminal_job_id
	if not job_id then
		return false
	end

	return vim.fn.jobwait({ job_id }, 0)[1] == -1
end

local function terminal_cmd()
	local shell = vim.o.shell

	if shell and shell ~= "" then
		return { shell }
	end

	return { vim.env.SHELL or "sh" }
end

local function apply_terminal_window_options(win)
	float_win.apply_minimal_options(win)
end

local function close_terminal_window()
	local win = visible_terminal_win() or state.win

	if valid_win(win) then
		float_win.untrack(win)
		pcall(vim.api.nvim_win_close, win, true)
	end

	state.win = nil
	-- Keep state.layout. It stores the last-used layout.
end

function M.close()
	close_terminal_window()
end

local function set_terminal_keymaps(buf)
	vim.keymap.set("t", "<C-x>", [[<C-\><C-n>]], {
		buffer = buf,
		silent = true,
		desc = "Exit terminal mode",
	})

	vim.keymap.set("t", "<C-t>", function()
		M.toggle()
	end, {
		buffer = buf,
		silent = true,
		desc = "Toggle terminal",
	})

	for _, key in ipairs({ "h", "j", "k", "l" }) do
		vim.keymap.set("t", "<C-w>" .. key, function()
			if state.layout == "float" then
				M.close()
				return
			end

			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-\\><C-n><C-w>" .. key, true, false, true),
				"n",
				false
			)
		end, {
			buffer = buf,
			silent = true,
			desc = "Terminal window navigation",
		})

		vim.keymap.set("n", "<C-w>" .. key, function()
			if state.layout == "float" and valid_win(state.win) and vim.api.nvim_get_current_win() == state.win then
				M.close()
				return
			end

			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>" .. key, true, false, true), "n", false)
		end, {
			buffer = buf,
			silent = true,
			desc = "Terminal window navigation",
		})
	end
end

local function create_terminal_buffer()
	local buf = vim.api.nvim_create_buf(false, true)

	vim.b[buf].maxvim_terminal = true

	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "terminal"

	vim.api.nvim_buf_call(buf, function()
		vim.fn.jobstart(terminal_cmd(), { term = true })
	end)

	set_terminal_keymaps(buf)

	state.buf = buf
	return buf
end

local function ensure_terminal_buffer()
	if terminal_is_alive(state.buf) then
		return state.buf
	end

	if valid_buf(state.buf) then
		pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
	end

	state.buf = nil
	return create_terminal_buffer()
end

local function open_left(buf)
	vim.cmd("topleft vertical split")

	local win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_width(win, config.split.width)

	return win
end

local function open_right(buf)
	vim.cmd("botright vertical split")

	local win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_width(win, config.split.width)

	return win
end

local function open_top(buf)
	vim.cmd("topleft split")

	local win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_height(win, config.split.height)

	return win
end

local function open_bottom(buf)
	vim.cmd("botright split")

	local win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_height(win, config.split.height)

	return win
end

local function open_float(buf)
	return float_win.open(buf, true, function()
		return config.float
	end, function(win)
		if valid_buf(state.buf) then
			float_win.resize_term_job(vim.b[state.buf].terminal_job_id, win)
		end
	end)
end

local open_layout = {
	left = open_left,
	right = open_right,
	top = open_top,
	bottom = open_bottom,
	float = open_float,
}

function M.toggle(layout)
	layout = layout or state.layout or "bottom"

	local current = visible_terminal_win()

	if current and state.layout == layout then
		close_terminal_window()
		return
	end

	if current then
		close_terminal_window()
	end

	local opener = open_layout[layout]
	if not opener then
		vim.notify(("Unknown terminal layout: %s"):format(layout), vim.log.levels.ERROR)
		return
	end

	local buf = ensure_terminal_buffer()
	local win = opener(buf)

	state.win = win
	state.layout = layout

	apply_terminal_window_options(win)

	if layout ~= "float" then
		float_win.resize_term_job(vim.b[buf].terminal_job_id, win)
	end

	vim.api.nvim_set_current_win(win)
	vim.cmd.startinsert()
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	vim.api.nvim_clear_autocmds({ group = augroup })

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		group = augroup,
		callback = function()
			if not config.float.close_on_leave then
				return
			end

			vim.schedule(function()
				if state.layout ~= "float" then
					return
				end

				if not valid_win(state.win) then
					return
				end

				if vim.api.nvim_get_current_win() ~= state.win then
					M.close()
				end
			end)
		end,
	})
end

return M
