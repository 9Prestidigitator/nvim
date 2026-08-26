local required_dirs = {
	"~/notes",
}
for _, path in ipairs(required_dirs) do
	if vim.fn.isdirectory(vim.fn.expand(path)) ~= 1 then
		return
	end
end

	require("obsidian").setup({
	workspaces = {
		{
			name = "notes",
			path = "~/notes",
		},
	},
	ui = {
		enable = false,
	},
})
