vim.g.vimtex_view_method = "zathura"
vim.vimtex_compiler_method = "latexmk"
vim.opt.conceallevel = 1
vim.g.tex_conceal = "abdmg"
vim.g.vimtex_view_forward_search_on_start = false
vim.g.vimtex_compiler_latexmk = {
  aux_dir = "~/.cache/.texfiles/",
  out_dir = "~/.cache/tex/"
}
