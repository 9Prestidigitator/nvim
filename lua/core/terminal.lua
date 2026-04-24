local float_win = require("core.float_win")

local M = {}

local state = {
	buf = nil,
	win = nil,
	job = nil,
	layout = "bottom",
}

local config = {
	split = {
		width = 36,
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
		resize_delay_ms = 20,
	},
}

local augroup = vim.api.nvim_create_augroup("PopupTerminal", { clear = true })

local function visible_terminal_win()
	return float_win.visible_win_for_buf(state.buf)
end

function M.is_open()
	return float_win.valid_win(visible_terminal_win() or state.win)
end

local function terminal_cmd()
	local shell = vim.o.shell

	if shell and shell ~= "" then
		return { shell }
	end

	return { vim.env.SHELL or "sh" }
end

local function close_terminal_windows()
	float_win.close_wins_for_buf(state.buf)
	state.win = nil
end

local function close_terminal_window(win)
	win = win or visible_terminal_win() or state.win
	if float_win.valid_win(win) then
		float_win.close(win)
	end
	state.win = nil
end

function M.close()
	close_terminal_windows()
end

local function feedkeys(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
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

			feedkeys("<C-\\><C-n><C-w>" .. key)
		end, {
			buffer = buf,
			silent = true,
			desc = "Terminal window navigation",
		})

		vim.keymap.set("n", "<C-w>" .. key, function()
			if
				state.layout == "float"
				and float_win.valid_win(state.win)
				and vim.api.nvim_get_current_win() == state.win
			then
				M.close()
				return
			end

			feedkeys("<C-w>" .. key)
		end, {
			buffer = buf,
			silent = true,
			desc = "Terminal window navigation",
		})
	end
end

local function create_terminal_buffer()
	local buf, job, err = float_win.create_term_buf(terminal_cmd(), {
		filetype = "terminal",
		vars = {
			maxvim_terminal = true,
		},
		on_exit = function(job_id)
			if state.job ~= job_id then
				return
			end

			vim.schedule(function()
				if float_win.valid_win(state.win) then
					close_terminal_window()
				end

				state.buf = nil
				state.job = nil
			end)
		end,
	})

	if not buf then
		vim.notify(("Failed to start terminal: %s"):format(err or "unknown error"), vim.log.levels.ERROR)
		return nil
	end

	state.buf = buf
	state.job = job

	set_terminal_keymaps(buf)

	return buf
end

local function ensure_terminal_buffer()
	if float_win.valid_buf(state.buf) and float_win.job_is_running(state.job) then
		return state.buf
	end

	if float_win.valid_buf(state.buf) then
		pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
	end

	state.buf = nil
	state.job = nil

	return create_terminal_buffer()
end

local function open_split(buf, layout)
	local size = (layout == "left" or layout == "right") and config.split.width or config.split.height

	local win, err = float_win.open_split(buf, layout, size)
	if not win then
		vim.notify(err, vim.log.levels.ERROR)
		return nil
	end

	float_win.resize_term_job(state.job, win)

	return win
end

local function open_float(buf)
	local win = float_win.open(buf, true, function()
		return config.float
	end, function(resized_win)
		float_win.resize_term_job(state.job, resized_win)
	end, {
		resize_delay_ms = config.float.resize_delay_ms,
	})

	float_win.resize_term_job(state.job, win)

	return win
end

local open_layout = {
	left = function(buf)
		return open_split(buf, "left")
	end,
	right = function(buf)
		return open_split(buf, "right")
	end,
	top = function(buf)
		return open_split(buf, "top")
	end,
	bottom = function(buf)
		return open_split(buf, "bottom")
	end,
	float = open_float,
}

function M.toggle(layout)
	layout = layout or state.layout or "bottom"

	local current = visible_terminal_win()

	if current and state.layout == layout then
		close_terminal_window()
		return
	end

    close_terminal_windows()

	local opener = open_layout[layout]
	if not opener then
		vim.notify(("Unknown terminal layout: %s"):format(layout), vim.log.levels.ERROR)
		return
	end

	local buf = ensure_terminal_buffer()
	if not buf then
		return
	end

	local win = opener(buf)
	if not win then
		return
	end

	state.win = win
	state.layout = layout

	float_win.apply_minimal_options(win)

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

				if not float_win.valid_win(state.win) then
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
