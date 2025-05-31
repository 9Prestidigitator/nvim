-- There may be a better way to remap these, but this will do for now

vim.g.lists_filetypes = { "markdown", "md" }

vim.keymap.set("n", "<leader>qlk", "<Plug>(lists-moveup)", { desc = "Move List Item Up" })
vim.keymap.set("n", "<leader>qlj", "<Plug>(lists-movedown)", { desc = "Move List Item Down" })
vim.keymap.set("n", "<leader>qlu", "<Plug>(lists-uniq)", { desc = "Remove repetitions in list" })
vim.keymap.set(
  "n",
  "<leader>qlU",
  "<Plug>(lists-uniq-local)",
  { desc = "Remove repetitions within current list depth" }
)
vim.keymap.set(
  "n",
  "<leader>qlT",
  "<Plug>(lists-bullet-toggle-local)",
  { desc = "Toggle bullet point for sibling list" }
)
vim.keymap.set("n", "<leader>qlt", "<Plug>(lists-bullet-toggle-all)", { desc = "toggle bullet point for entire list" })
vim.keymap.set("n", "<leader>qlL", "<Plug>(lists-show-item)", { desc = "Show list item" })

vim.keymap.set("n", "<leader>qlp", "<Plug>(lists-toggle)", { desc = "Lists Toggle" })
