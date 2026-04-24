local M = {}

local resize_states = {}

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
	local resolved = value <= 1 and math.floor(total * value) or value
	return math.max(resolved, min or 1)
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
		row = math.max(0, math.floor((lines - total_height) / 2)),
		col = math.max(0, math.floor((columns - total_width) / 2)),
	}
end

function M.on_resize(group, callback, opts)
	opts = opts or {}

	local debounce_ms = opts.debounce_ms or opts.settle_ms or 40
	local group_key = tostring(group)
	local state = resize_states[group_key] or {}

	if state.timer then
		state.timer:stop()
	end
	state.timer = vim.uv.new_timer()
	state.seq = 0
	state.last_columns = vim.o.columns
	state.last_lines = vim.o.lines
	resize_states[group_key] = state

	local function fire()
		vim.schedule(function()
			if vim.v.exiting and vim.v.exiting ~= 0 then
				return
			end
			callback()
		end)
	end

	local function request_resize()
		state.seq = state.seq + 1
		local seq = state.seq

		state.timer:stop()
		state.timer:start(debounce_ms, 0, function()
			if state.timer:is_closing() or seq ~= state.seq then
				return
			end
			fire()
		end)
	end

	vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
		group = group,
		callback = function()
			local columns = vim.o.columns
			local lines = vim.o.lines

			if columns == state.last_columns and lines == state.last_lines then
				return
			end

			state.last_columns = columns
			state.last_lines = lines
			request_resize()
		end,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		once = true,
		callback = function()
			if state.timer and not state.timer:is_closing() then
				state.timer:stop()
				state.timer:close()
			end

			resize_states[group_key] = nil
		end,
	})
end

function M.resize(win, opts)
	if not M.valid_win(win) then
		return false
	end

	if not M.is_float(win) then
		return false
	end

	local ok, err = pcall(vim.api.nvim_win_set_config, win, M.centered_config(opts))
	if not ok then
		vim.notify(("float resize failed: %s"):format(err), vim.log.levels.WARN)
		return false
	end
	return true
end
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
