-- This directory acts as the stem of my brain
vim.g.wiki_root = '~/wiki'

-- Wiki.vim Keybindings!
vim.keymap.set("n", "<leader>w.", "<Plug>(wiki-link-next)", {desc = "next link"})
vim.keymap.set("n", "<leader>w,", "<Plug>(wiki-link-prev)", {desc = "previous link"})

