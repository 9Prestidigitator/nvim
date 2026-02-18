require("mini.pick").setup({
	mappings = {
		toggle_info = "<C-k>",
		toggle_preview = "<C-p>",
		move_down = "<Tab>",
		move_up = "<S-Tab>",
	},
})

vim.api.nvim_create_user_command("PickRecentFiles", function()
	local pick = require("mini.pick")
	local icons = require("mini.icons")
	local files = vim.tbl_filter(function(f)
		return vim.fn.filereadable(f) == 1
	end, vim.v.oldfiles or {})
	local items = vim.tbl_map(function(path)
		local icon, _ = icons.get("file", vim.fn.fnamemodify(path, ":t"))
		return string.format("%s %s", icon or " ", path)
	end, files)
	pick.start({
		source = {
			name = "Recent Files",
			items = items,
			choose = function(item)
				local path = item:match("^.-%s+(.*)$")
				vim.schedule(function()
					vim.cmd("edit " .. vim.fn.fnameescape(path))
				end)
			end,
		},
	})
end, {})

vim.api.nvim_create_user_command("PickAllFiles", function()
	local pick = require("mini.pick")
	local icons = require("mini.icons")

	local cwd = vim.uv.cwd()

	cwd = vim.fs.normalize(vim.fn.fnamemodify(cwd, ":p"))
	local cwd_pat = "^" .. vim.pesc(cwd:gsub("\\", "/")) .. "/?"

	local ignore_dirs = { ".git", "build" }

	local function is_ignored(abs)
		local p = abs:gsub("\\", "/")
		for _, d in ipairs(ignore_dirs) do
			local dir = d:gsub("%.", "%%.")
			if p:find("/" .. dir .. "/") or p:match("/" .. dir .. "$") then
				return true
			end
		end
		return false
	end

	local function relpath(abs)
		abs = vim.fs.normalize(vim.fn.fnamemodify(abs, ":p"))
		local rel = vim.fs.relpath(abs, cwd)
		if rel and rel ~= "" then
			return rel
		end
		local p = abs:gsub("\\", "/")
		return (p:gsub(cwd_pat, ""))
	end

	local files = vim.fs.find(function(name, path)
		local abs = vim.fs.joinpath(path, name)
		return not is_ignored(abs)
	end, {
		path = cwd,
		type = "file",
		limit = math.huge,
		hidden = true,
		-- follow = true,
	})

	table.sort(files)

	local items = vim.iter(files)
		:map(function(abs)
			local rel = relpath(abs)
			local name = vim.fs.basename(abs)
			local icon = icons.get("file", name) or " "
			return { text = ("%s %s"):format(icon, rel), abs = abs }
		end)
		:totable()

	pick.start({
		source = {
			name = "Pick all files in cwd",
			items = items,
			format = function(item)
				return item.text
			end,
			choose = function(item)
				vim.schedule(function()
					vim.cmd.edit(vim.fn.fnameescape(item.abs))
				end)
			end,
		},
	})
end, {})

vim.api.nvim_create_user_command("PickTabs", function()
	local pick = require("mini.pick")
	local tabs = vim.api.nvim_list_tabpages()
	local items = vim.tbl_map(function(tab)
		local win = vim.api.nvim_tabpage_get_win(tab)
		local buf = vim.api.nvim_win_get_buf(win)
		local full = vim.api.nvim_buf_get_name(buf)
		local name = (full == "" and "[No Name]") or vim.fn.fnamemodify(full, ":t")

		local nr = vim.api.nvim_tabpage_get_number(tab)
		return { tab = tab, text = ("[%d] %s"):format(nr, name) }
	end, tabs)
	pick.start({
		source = {
			name = "Tabs",
			items = items,
			format = function(item)
				return item.text
			end,
			choose = function(item)
				vim.schedule(function()
					vim.api.nvim_set_current_tabpage(item.tab)
				end)
			end,
		},
	})
end, {})

vim.api.nvim_create_user_command("PickKeymaps", function()
	local pick = require("mini.pick")
	local mode_names = {
		n = "Normal",
		i = "Insert",
		v = "Visual",
		x = "Visual",
		s = "Select",
		o = "Operator-pending",
		c = "Command-line",
		t = "Terminal",
	}
	local all_modes = { "n", "i", "v", "x", "s", "o", "c", "t" }
	local items = {}

	for _, mode in ipairs(all_modes) do
		local maps = vim.api.nvim_get_keymap(mode)
		for _, map in ipairs(maps) do
			local mode_label = mode_names[mode] or mode
			local desc = map.desc or ""
			table.insert(items, string.format("[%s] %-15s → %-40s %s", mode_label, map.lhs, map.rhs, desc))
		end
	end

	pick.start({
		source = {
			name = "Keymaps",
			items = items,
			choose = function(item)
				local lhs = item:match("%] (%S+)")
				vim.cmd("verbose map " .. lhs)
			end,
		},
		window = {
			config = {
				width = 120,
			},
		},
	})
end, {})
