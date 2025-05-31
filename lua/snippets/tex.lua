local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local h = require("snippets.tex_helpers") -- load context helpers

-- begin / end environment
ls.add_snippets("tex", {
  s({ trig = "beg", dscr = "begin{} / end{}" }, fmt([[
    \begin{{{}}}{}
    	{}
    \end{{{}}}
    {}
  ]], { i(1), i(2), i(3), rep(1), i(0) })),
})

-- inline math
ls.add_snippets("tex", {
  s({ trig = "mk", wordTrig = true, dscr = "Inline Math" }, fmt("${}{}", {
    i(1),
    f(function(_, snip)
      local prev = snip.captures[1] or ""
      if prev:match("[,%.%?%-%s]$") then
        return ""
      end
      return " "
    end, {}),
  })),
})

-- display math
ls.add_snippets("tex", {
  s({ trig = "dm", wordTrig = true, dscr = "Display Math" }, fmt([[
    \[
    {}
    \] {}
  ]], { i(1), i(0) })),
})

-- \frac snippet
ls.add_snippets("tex", {
  s({ trig = "//", wordTrig = true }, fmt("\\frac{{{}}}{{{}}}{}", {
    i(1), i(2), i(0)
  })),
})
