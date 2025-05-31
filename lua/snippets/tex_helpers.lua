local helpers = {}

helpers.in_mathzone = function()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

helpers.in_comment = function()
  return vim.fn['vimtex#syntax#in_comment']() == 1
end

helpers.in_env = function(name)
  local inside = vim.fn['vimtex#env#is_inside'](name)
  return inside[1] ~= '0' and inside[2] ~= '0'
end

return helpers
