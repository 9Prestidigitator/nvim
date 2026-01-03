require("auto-session").setup({
	suppressed_dirs = {
		"~/",
		"~/Documents",
		"~/Downloads",
        "~/notes",
	},
})
vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
