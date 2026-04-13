require("flash").setup({
	labels = "asdfghjklqwertyuiopzxcvbnm",
	search = {
		multi_window = false,
		forward = true,
		wrap = true,
	},
	modes = {
		search = {
			enabled = true,
		},
		char = {
			enabled = true,
			jump_labels = true,
		},
	},
})
