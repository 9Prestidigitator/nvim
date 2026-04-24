local M = {}

local tracked_windows = {}
local resize_augroup = vim.api.nvim_create_augroup("FloatWindow", { clear = true })
local resize_delay_ms = 20

function M.valid_win(win)
	return win and vim.api.nvim_win_is_valid(win)
end

function M.valid_buf(buf)
	return buf and vim.api.nvim_buf_is_valid(buf)
end

function M.is_float(win)
	if not M.valid_win(win) then
		return false
	end

	local config = vim.api.nvim_win_get_config(win)
	return config.relative ~= ""
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

local function percent_or_absolute(value, total, min)
	local resolved = value <= 1 and math.ceil(total * value) or value
	return math.max(resolved, min or 1)
end

local function has_border(border)
	return border and border ~= "none"
end

function M.centered_config(opts)
	opts = opts or {}

	local columns = vim.o.columns
	local lines = vim.o.lines

	local border_extra = has_border(opts.border) and 2 or 0
	local margin = opts.margin or 2

	local min_width = opts.min_width or 20
	local min_height = opts.min_height or 5

	local width = percent_or_absolute(opts.width or 0.88, columns, min_width)
	local height = percent_or_absolute(opts.height or 0.80, lines, min_height)

	width = math.min(width, math.max(min_width, columns - border_extra - margin * 2))
	height = math.min(height, math.max(min_height, lines - border_extra - margin * 2))

	local total_width = width + border_extra
	local total_height = height + border_extra

	return {
		relative = "editor",
		style = "minimal",
		border = opts.border or "rounded",
		title = opts.title,
		title_pos = opts.title_pos or "center",
		zindex = opts.zindex or 50,
		width = width,
		height = height,
		row = math.max(0, math.ceil(lines - total_height) / 2),
		col = math.max(0, math.ceil(columns - total_width) / 2),
	}
end

local function resolve_opts(opts)
	if type(opts) == "function" then
		opts = opts()
	end

	return opts or {}
end

local function apply_tracked_resize(win)
	local entry = tracked_windows[win]
	if not entry then
		return false
	end

	if not M.valid_win(win) or not M.is_float(win) then
		tracked_windows[win] = nil
		return false
	end

	local resolved_opts = resolve_opts(entry.opts)
	local ok, err = pcall(vim.api.nvim_win_set_config, win, M.centered_config(resolved_opts))
	if not ok then
		tracked_windows[win] = nil
		vim.notify(("float resize failed: %s"):format(err), vim.log.levels.WARN)
		return false
	end

	if entry.after_resize then
		pcall(entry.after_resize, win, resolved_opts)
	end

	return true
end

function M.resize(win, opts)
	if not M.valid_win(win) then
		return false
	end

	if not M.is_float(win) then
		return false
	end

	local ok, err = pcall(vim.api.nvim_win_set_config, win, M.centered_config(resolve_opts(opts)))
	if not ok then
		vim.notify(("float resize failed: %s"):format(err), vim.log.levels.WARN)
		return false
	end
	return true
end

function M.track(win, opts, after_resize)
	if not M.valid_win(win) or not M.is_float(win) then
		return false
	end

	tracked_windows[win] = {
		opts = opts,
		after_resize = after_resize,
	}

	return apply_tracked_resize(win)
end

function M.untrack(win)
	tracked_windows[win] = nil
end

function M.open(buf, enter, opts, after_resize)
	local win = vim.api.nvim_open_win(buf, enter ~= false, M.centered_config(resolve_opts(opts)))
	M.track(win, opts, after_resize)
	return win
end

vim.api.nvim_create_autocmd("VimResized", {
	group = resize_augroup,
	callback = function()
		vim.defer_fn(function()
			if vim.v.exiting and vim.v.exiting ~= 0 then
				return
			end

			vim.schedule(function()
				for win, _ in pairs(tracked_windows) do
					apply_tracked_resize(win)
				end
			end)
		end, resize_delay_ms)
	end,
})

vim.api.nvim_create_autocmd("WinClosed", {
	group = resize_augroup,
	callback = function(args)
		tracked_windows[tonumber(args.match)] = nil
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = resize_augroup,
	once = true,
	callback = function()
		for win, _ in pairs(tracked_windows) do
			tracked_windows[win] = nil
		end
	end,
})

function M.resize_term_job(job, win)
	if not job or job <= 0 or not M.valid_win(win) then
		return
	end
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)
	pcall(vim.fn.jobresize, job, width, height)
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
end

return M
