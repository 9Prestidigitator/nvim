local float_win = require("core.float_win")

local M = {}

local state = {}

local config = {
	defaults = {
		width = 0.88,
		height = 0.84,
		border = "rounded",
		title_pos = "center",
		zindex = 60,
		resize_delay_ms = 160,
		cwd = function()
			return vim.fn.getcwd()
		end,
	},
	apps = {},
}

local augroup = vim.api.nvim_create_augroup("FloatTui", { clear = true })

local function app_state(name)
	state[name] = state[name] or {
		buf = nil,
		win = nil,
		job = nil,
	}

	return state[name]
end

local function app_config(name)
	local app = config.apps[name]
	if not app then
		return nil
	end

	return vim.tbl_deep_extend("force", {}, config.defaults, {
		name = name,
		title = " " .. name .. " ",
		filetype = name,
	}, app)
end

local function app_cmd(app)
	return float_win.normalize_cmd(app.cmd)
end

function M.is_available(name)
	local app = app_config(name)
	if not app then
		return false
	end

	local cmd = app_cmd(app)
	return cmd and cmd[1] and vim.fn.executable(cmd[1]) == 1
end

local function set_buffer_keymaps(name, buf)
	vim.keymap.set({ "t", "n" }, "<C-t>", function()
		M.hide(name)
	end, {
		buffer = buf,
		silent = true,
		desc = "Hide floating TUI",
	})

	for _, lhs in ipairs({
		"<C-x>",
		"<C-w>h",
		"<C-w>j",
		"<C-w>k",
		"<C-w>l",
	}) do
		vim.keymap.set({ "t", "n" }, lhs, "<Nop>", {
			buffer = buf,
			silent = true,
			nowait = true,
		})
	end
end

function M.hide(name)
	local s = app_state(name)
	local win = float_win.visible_win_for_buf(s.buf) or s.win

	if float_win.valid_win(win) then
		float_win.close(win)
	end

	s.win = nil
end

function M.cleanup(name)
	local s = app_state(name)

	M.hide(name)

	if float_win.valid_buf(s.buf) then
		pcall(vim.api.nvim_buf_delete, s.buf, { force = true })
	end

	state[name] = nil
end

local function create_buffer(name, app)
	local s = app_state(name)
	local cmd = app_cmd(app)

	if not cmd or not cmd[1] then
		vim.notify(("No command configured for float_tui app: %s"):format(name), vim.log.levels.ERROR)
		return nil
	end

	if vim.fn.executable(cmd[1]) ~= 1 then
		vim.notify(("Executable not found: %s"):format(cmd[1]), vim.log.levels.ERROR)
		return nil
	end

	local buf, job, err = float_win.create_term_buf(cmd, {
		cwd = app.cwd,
		filetype = app.filetype,
		vars = {
			maxvim_float_tui = name,
		},
		on_exit = function(job_id)
			if s.job ~= job_id then
				return
			end

			vim.schedule(function()
				M.cleanup(name)
			end)
		end,
	})

	if not buf then
		vim.notify(("Failed to start float_tui app %s: %s"):format(name, err or "unknown error"), vim.log.levels.ERROR)
		return nil
	end

	s.buf = buf
	s.job = job

	set_buffer_keymaps(name, buf)

	return buf
end

local function ensure_buffer(name, app)
	local s = app_state(name)

	if float_win.valid_buf(s.buf) and float_win.job_is_running(s.job) then
		return s.buf
	end

	M.cleanup(name)
	return create_buffer(name, app)
end

function M.open(name)
	local app = app_config(name)
	if not app then
		vim.notify(("Unknown float_tui app: %s"):format(name), vim.log.levels.ERROR)
		return
	end

	local s = app_state(name)
	local existing_win = float_win.visible_win_for_buf(s.buf)

	if float_win.valid_win(existing_win) then
		s.win = existing_win
		vim.api.nvim_set_current_win(existing_win)
		vim.cmd.startinsert()
		return
	end

	local buf = ensure_buffer(name, app)
	if not buf then
		return
	end

	local win = float_win.open(
		buf,
		true,
		function()
			return app_config(name) or app
		end,
		function(resized_win)
			float_win.resize_term_job(s.job, resized_win)
		end,
		{
			resize_delay_ms = app.resize_delay_ms,
			redraw = app.redraw,
		}
	)

	s.win = win

	float_win.resize_term_job(s.job, win)

	vim.api.nvim_set_current_win(win)
	vim.cmd.startinsert()
end

function M.toggle(name)
	local s = app_state(name)

	if float_win.valid_win(float_win.visible_win_for_buf(s.buf) or s.win) then
		M.hide(name)
	else
		M.open(name)
	end
end

function M.map(name)
	local app = app_config(name)

	if not app or not app.key then
		return
	end

	if not M.is_available(name) then
		return
	end

	vim.keymap.set("n", app.key, function()
		M.toggle(name)
	end, {
		desc = app.desc or app.title or name,
		silent = true,
	})
end

local function command_name_from_app_name(name)
	local command = name:gsub("[-_](%w)", function(char)
		return char:upper()
	end)

	command = command:gsub("^%l", string.upper)

	return "FloatTui" .. command
end

local function create_generic_command()
	pcall(vim.api.nvim_del_user_command, "FloatTui")

	vim.api.nvim_create_user_command("FloatTui", function(opts)
		M.toggle(opts.args)
	end, {
		nargs = 1,
		complete = function()
			local names = {}

			for name, _ in pairs(config.apps) do
				if M.is_available(name) then
					table.insert(names, name)
				end
			end

			table.sort(names)
			return names
		end,
	})
end

local function create_app_command(name)
	local app = app_config(name)

	if not app or not app.command then
		return
	end

	if not M.is_available(name) then
		return
	end

	local command = app.command == true and command_name_from_app_name(name) or app.command

	pcall(vim.api.nvim_del_user_command, command)

	vim.api.nvim_create_user_command(command, function()
		M.toggle(name)
	end, {})
end

function M.register(name, spec)
	config.apps[name] = vim.tbl_deep_extend("force", config.apps[name] or {}, spec or {})

	M.map(name)
	create_app_command(name)
end

function M.setup(opts)
	opts = opts or {}

	local apps = opts.apps or {}
	opts.apps = nil

	config = vim.tbl_deep_extend("force", config, opts)

	vim.api.nvim_clear_autocmds({ group = augroup })

	create_generic_command()

	for name, spec in pairs(apps) do
		M.register(name, spec)
	end
end

return M
