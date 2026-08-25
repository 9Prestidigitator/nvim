local workspaces = {}
local notes_path = vim.fn.expand("~/notes")

if vim.fn.isdirectory(notes_path) == 1 then
	table.insert(workspaces, {
		name = "notes",
		path = notes_path,
	})
end

require("obsidian").setup({
	workspaces = workspaces,
	ui = {
		enable = false,
	},
})
