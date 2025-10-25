
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
	local oldfiles = vim.v.oldfiles or {}
	local files = vim.tbl_filter(function(f)
		return vim.fn.filereadable(f) == 1 -- Filter only readable files
	end, oldfiles)
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
