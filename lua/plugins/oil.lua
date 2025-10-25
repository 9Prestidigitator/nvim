require("oil").setup({
	default_file_explorer = true,
	view_options = {
		show_hidden = true,
	},
	win_options = {
		signcolumn = "number",
	},
	keymaps = {
		["<leader>e"] = { "actions.close", mode = "n" },
	},
})

local StatusType = require("oil-vcs-status.constant.status").StatusType

require("oil-vcs-status").setup({
	status_symbol = {
		[StatusType.Added] = "",
		[StatusType.Copied] = "󰆏",
		[StatusType.Deleted] = "",
		[StatusType.Ignored] = "",
		[StatusType.Modified] = "",
		[StatusType.Renamed] = "",
		[StatusType.TypeChanged] = "󰉺",
		[StatusType.Unmodified] = " ",
		[StatusType.Unmerged] = "",
		[StatusType.Untracked] = "",
		[StatusType.External] = "",

		[StatusType.UpstreamAdded] = "󰈞",
		[StatusType.UpstreamCopied] = "󰈢",
		[StatusType.UpstreamDeleted] = "",
		[StatusType.UpstreamIgnored] = " ",
		[StatusType.UpstreamModified] = "󰏫",
		[StatusType.UpstreamRenamed] = "",
		[StatusType.UpstreamTypeChanged] = "󱧶",
		[StatusType.UpstreamUnmodified] = " ",
		[StatusType.UpstreamUnmerged] = "",
		[StatusType.UpstreamUntracked] = " ",
		[StatusType.UpstreamExternal] = "",
	},
})
