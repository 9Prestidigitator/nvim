-- This directory acts as the stem of my brain
vim.g.wiki_root = '~/wiki'

-- Changing leader key to this since <leader>w is whickey, which makes more sense imo
vim.g.wiki_mappings_prefix = "<leader>q"

-- Wiki.vim Keybindings!
vim.keymap.set("n", "<leader>q.", "<Plug>(wiki-link-next)", {desc = "next link"})
vim.keymap.set("n", "<leader>q,", "<Plug>(wiki-link-prev)", {desc = "previous link"})

