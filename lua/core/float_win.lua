local M = {}

local tracked_windows = {}
local resize_timers = {}

local resize_augroup = vim.api.nvim_create_augroup("FloatWindow", { clear = true })

-- True if window is valid, false otherwise or if nil provided.
-- @param win window to check if valid
function M.valid_win(win)
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

-- True if buffer is valid, false otherwise or if nil provided.
-- @param buf buffer to check if valid
function M.valid_buf(buf)
	return buf ~= nil and vim.api.nvim_buf_is_valid(buf)
end

-- If a function is provided, then evaluate function otherwise provide standard value.
function M.resolve(value)
	if type(value) == "function" then
		return value()
	end
	return value
end

-- Uses M.resolve() to resolve any functions. Then if a singular string is 
-- provided then treat it as a single element table with string.
function M.normalize_cmd(cmd)
	cmd = M.resolve(cmd)
	if type(cmd) == "string" then
		return { cmd }
	end
	return cmd
end

function M.job_is_running(job)
	return job ~= nil and job > 0 and vim.fn.jobwait({ job }, 0)[1] == -1
end

function M.is_float(win)
	if not M.valid_win(win) then
		return false
	end
	return vim.api.nvim_win_get_config(win).relative ~= ""
end

function M.visible_win_for_buf(buf)
	if not M.valid_buf(buf) then
		return nil
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if M.valid_win(win) and vim.api.nvim_win_get_buf(win) == buf then
			return win
		end
	end
	return nil
end

function M.wins_for_buf(buf)
	if not M.valid_buf(buf) then
		return {}
	end
	local wins = {}
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
			if M.valid_win(win) and vim.api.nvim_win_get_buf(win) == buf then
				table.insert(wins, win)
			end
		end
	end
	return wins
end

function M.close_wins_for_buf(buf, except_win)
	for _, win in ipairs(M.wins_for_buf(buf)) do
		if win ~= except_win then
			M.close(win)
		end
	end
end

local function percent_or_absolute(value, total, minimum)
	local resolved = value <= 1 and math.floor(total * value) or value
	return math.max(resolved, minimum or 1)
end

local function has_border(border)
	return border and border ~= "none"
end

function M.centered_config(opts)
	opts = opts or {}

	local columns = vim.o.columns
	local lines = vim.o.lines - vim.o.cmdheight
	local border_extra = has_border(opts.border) and 2 or 0
	local margin = opts.margin or 2

	local min_width = opts.min_width or 20
	local min_height = opts.min_height or 5
	local max_width = math.max(1, columns - border_extra - margin * 2)
	local max_height = math.max(1, lines - border_extra - margin * 2)

	local width = percent_or_absolute(opts.width or 0.88, columns, min_width)
	local height = percent_or_absolute(opts.height or 0.80, lines, min_height)
	width = math.min(width, max_width)
	height = math.min(height, max_height)
	local total_width = width + border_extra
	local total_height = height + border_extra
	return {
		relative = "editor",
		style = opts.style or "minimal",
		border = opts.border or "rounded",
		title = opts.title,
		title_pos = opts.title_pos or "center",
		zindex = opts.zindex or 50,
		width = width,
		height = height,
		row = math.max(0, math.floor((lines - total_height) / 2)),
		col = math.max(0, math.floor((columns - total_width) / 2)),
	}
end

function M.apply_minimal_options(win)
	if not M.valid_win(win) then
		return
	end

	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].foldcolumn = "0"
	vim.wo[win].list = false
	vim.wo[win].spell = false
	vim.wo[win].wrap = false
	vim.wo[win].sidescrolloff = 0
end

function M.resize_term_job(job, win)
	if not M.job_is_running(job) or not M.valid_win(win) then
		return
	end

	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)

	pcall(vim.fn.jobresize, job, width, height)
end

function M.create_term_buf(cmd, opts)
	opts = opts or {}
	local normalized_cmd = M.normalize_cmd(cmd)
	if not normalized_cmd or not normalized_cmd[1] then
		return nil, nil, "missing terminal command"
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = opts.bufhidden or "hide"
	vim.bo[buf].swapfile = false
	if opts.filetype then
		vim.bo[buf].filetype = opts.filetype
	end
	for key, value in pairs(opts.vars or {}) do
		vim.b[buf][key] = value
	end
	local job
	vim.api.nvim_buf_call(buf, function()
		job = vim.fn.jobstart(normalized_cmd, {
			term = true,
			cwd = M.resolve(opts.cwd),
			env = opts.env,
			on_exit = opts.on_exit,
		})
	end)
	if not job or job <= 0 then
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		return nil, nil, "failed to start terminal job"
	end
	return buf, job, nil
end

local function apply_resize(win)
	local entry = tracked_windows[win]
	if not entry then
		return false
	end
	if not M.valid_win(win) or not M.is_float(win) then
		tracked_windows[win] = nil
		return false
	end
	local opts = M.resolve(entry.opts) or {}
	local ok, err = pcall(vim.api.nvim_win_set_config, win, M.centered_config(opts))
	if not ok then
		tracked_windows[win] = nil
		vim.notify(("float resize failed: %s"):format(err), vim.log.levels.WARN)
		return false
	end
	M.apply_minimal_options(win)
	if entry.after_resize then
		pcall(entry.after_resize, win, opts)
	end
	if entry.redraw ~= false then
		vim.cmd("redraw!")
	end
	return true
end

local function cancel_resize_timer(win)
	local timer = resize_timers[win]
	if timer and not timer:is_closing() then
		timer:stop()
		timer:close()
	end

	resize_timers[win] = nil
end

local function schedule_resize(win)
	local entry = tracked_windows[win]
	if not entry then
		return
	end
	local delay = entry.resize_delay_ms or 40
	if delay <= 0 then
		vim.schedule(function()
			apply_resize(win)
		end)
		return
	end
	cancel_resize_timer(win)
	local timer = vim.uv.new_timer()
	resize_timers[win] = timer
	timer:start(delay, 0, function()
		cancel_resize_timer(win)
		vim.schedule(function()
			apply_resize(win)
		end)
	end)
end

function M.track(win, opts, after_resize, track_opts)
	if not M.valid_win(win) or not M.is_float(win) then
		return false
	end
	track_opts = track_opts or {}
	tracked_windows[win] = {
		opts = opts,
		after_resize = after_resize,
		resize_delay_ms = track_opts.resize_delay_ms,
		redraw = track_opts.redraw,
	}
	return apply_resize(win)
end

function M.untrack(win)
	cancel_resize_timer(win)
	tracked_windows[win] = nil
end

function M.resize(win, opts)
	if not M.valid_win(win) or not M.is_float(win) then
		return false
	end
	local ok, err = pcall(vim.api.nvim_win_set_config, win, M.centered_config(M.resolve(opts)))
	if not ok then
		vim.notify(("float resize failed: %s"):format(err), vim.log.levels.WARN)
		return false
	end
	M.apply_minimal_options(win)
	return true
end

function M.open(buf, enter, opts, after_resize, track_opts)
	local win = vim.api.nvim_open_win(buf, enter ~= false, M.centered_config(M.resolve(opts)))
	M.apply_minimal_options(win)
	M.track(win, opts, after_resize, track_opts)
	return win
end

function M.close(win)
	if not M.valid_win(win) then
		return
	end
	M.untrack(win)
	pcall(vim.api.nvim_win_close, win, true)
end

function M.open_split(buf, layout, size)
	local commands = {
		left = "topleft vertical split",
		right = "botright vertical split",
		top = "topleft split",
		bottom = "botright split",
	}
	local command = commands[layout]
	if not command then
		return nil, ("unknown split layout: %s"):format(layout)
	end
	vim.cmd(command)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	if layout == "left" or layout == "right" then
		vim.api.nvim_win_set_width(win, size)
	else
		vim.api.nvim_win_set_height(win, size)
	end
	M.apply_minimal_options(win)
	return win, nil
end

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
	group = resize_augroup,
	callback = function()
		for win, _ in pairs(tracked_windows) do
			schedule_resize(win)
		end
	end,
})

vim.api.nvim_create_autocmd("WinClosed", {
	group = resize_augroup,
	callback = function(args)
		M.untrack(tonumber(args.match))
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = resize_augroup,
	once = true,
	callback = function()
		for win, _ in pairs(tracked_windows) do
			M.untrack(win)
		end
	end,
})

return M
