_G.term_win_id = nil -- Store the window ID in a global variable to track it
_G.term_buf_id = nil

function _G.ToggleTerminal() -- This is the main function to toggle the terminal
	-- Check if the stored window ID is still valid
	if _G.term_win_id and vim.api.nvim_win_is_valid(_G.term_win_id) then
		-- Hide the window and clear our variable
		vim.api.nvim_win_hide(_G.term_win_id)
		_G.term_win_id = nil
	else
		-- If not, create a new terminal (or reuse existing buffer)
		vim.cmd("botright 12split")
		-- Check if we have a valid terminal buffer stored
		if _G.term_buf_id and vim.api.nvim_buf_is_valid(_G.term_buf_id) then
			-- Reuse the existing terminal buffer
			vim.api.nvim_win_set_buf(0, _G.term_buf_id)
		else
			-- Create a new terminal
			vim.cmd("terminal")
			_G.term_buf_id = vim.api.nvim_get_current_buf()
		end
		vim.cmd("startinsert")
		_G.term_win_id = vim.api.nvim_get_current_win() -- Store the new window's ID
	end
end

vim.api.nvim_create_autocmd("TermOpen", { -- Setup keymaps inside the terminal
	pattern = "*",
	callback = function(ctx)
		vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = ctx.buf, silent = true, desc = "Exit terminal mode" })
		vim.keymap.set(
			"t",
			"<C-t>",
			"<C-\\><C-n><Cmd>lua _G.ToggleTerminal()<CR>",
			{ buffer = ctx.buf, silent = true, desc = "Toggle terminal" }
		)
	end,
})

function AddPathsToConfig(dir, opts)
	opts = opts or {}
	local max_depth = opts.max_depth or 10
	local exclude_patterns = opts.exclude or { "^%.", "node_modules", ".git" }

	if not dir or vim.fn.isdirectory(dir) == 0 then
		vim.notify("Invalid directory: " .. tostring(dir), vim.log.levels.WARN)
		return
	end

	local paths = {}
	local visited = {}

	local function should_exclude(name)
		for _, pattern in ipairs(exclude_patterns) do
			if name:match(pattern) then
				return true
			end
		end
		return false
	end

	local function add_dir_patterns(path, depth)
		if depth > max_depth then
			return
		end

		-- Resolve symlinks to prevent cycles
		local real_path = vim.uv.fs_realpath(path) or path
		if visited[real_path] then
			return
		end
		visited[real_path] = true

		table.insert(paths, path .. "/?.lua")
		table.insert(paths, path .. "/?/init.lua")

		local ok, entries = pcall(vim.fs.dir, path)
		if ok then
			for name, type in entries do
				if type == "directory" and not should_exclude(name) then
					add_dir_patterns(path .. "/" .. name, depth + 1)
				end
			end
		end
	end

	add_dir_patterns(dir, 0)

	if #paths > 0 then
		package.path = package.path .. ";" .. table.concat(paths, ";")
	end

	if opts.verbose then
		vim.notify(string.format("Added %d paths from %s", #paths, dir), vim.log.levels.INFO)
	end
end
