
local venv_cache_file = vim.fn.stdpath "data" .. "/venv_cache.json"

local function load_venv_cache()
  -- Retrieves the most recent python VIRTUAL_EVN for the current directory
  local ok, data = pcall(vim.fn.readfile, venv_cache_file)
  if not ok then
    return {}
  end
  local ok2, decoded = pcall(vim.fn.json_decode, table.concat(data, "\n"))
  if not ok2 then
    return {}
  end
  return decoded
end

local function save_venv_cache(cache)
  -- Caches the most recent python VIRTUAL_EVN
  local encoded = vim.fn.json_encode(cache)
  local lines = vim.split(encoded, "\n")
  vim.fn.writefile(lines, venv_cache_file)
end

local function contains_py(cwd)
  local handle = vim.loop.fs_scandir(cwd)
  if not handle then
    return false
  end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "file" and name:match "%.py" then
      return true
    end
  end
  return false
end

local function auto_set_virtualenv()
  local cwd = vim.fn.getcwd()
  local venv_cache = load_venv_cache()

  if os.getenv "VIRTUAL_ENV" ~= nil then
    local set_venv = vim.env.VIRTUAL_ENV
    venv_cache[cwd] = set_venv
    save_venv_cache(venv_cache)
    print("🌟 Saved VIRTUAL_ENV: " .. set_venv)
    return
  end

  -- If cache knows the venv for this project, use it!
  if venv_cache[cwd] and vim.fn.filereadable(venv_cache[cwd] .. "/bin/activate") == 1 then
    vim.env.VIRTUAL_ENV = venv_cache[cwd]
    print("🌟 Loaded cached VIRTUAL_ENV: " .. venv_cache[cwd])
    return
  end

  -- Check if python is in directory
  if not contains_py(cwd) then
    return
  end

  -- Otherwise scan for env folders
  local handle = vim.loop.fs_scandir(cwd)
  if not handle then
    return
  end

  local candidates = {}

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "directory" and string.find(name, "env") then
      local possible_venv = cwd .. "/" .. name
      if vim.fn.filereadable(possible_venv .. "/bin/activate") == 1 then
        table.insert(candidates, possible_venv)
      end
    end
  end
  -- Prefer .venv if possible
  local preferred = nil
  for _, venv_path in ipairs(candidates) do
    if venv_path:match "/%.?venv$" then
      preferred = venv_path
      break
    end
  end
  if not preferred and #candidates > 0 then
    preferred = candidates[1]
  end

  -- Set and save
  if preferred then
    vim.env.VIRTUAL_ENV = preferred
    venv_cache[cwd] = preferred
    save_venv_cache(venv_cache)
    print("🌟 Detected and saved VIRTUAL_ENV: " .. preferred)
  end
end

auto_set_virtualenv()

-- Change venv in NVIM
function SwitchVenv()
  local cwd = vim.fn.getcwd()
  local local_envs = {}

  -- Find envs in current directory
  local handle = vim.loop.fs_scandir(cwd)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == "directory" and name:lower():find "env" then
        local possible_venv = cwd .. "/" .. name
        if vim.fn.filereadable(possible_venv .. "/bin/activate") == 1 then
          table.insert(local_envs, possible_venv)
        end
      end
    end
  end

  -- Load cached envs
  local cache = load_venv_cache()
  local cached_envs = {}

  for project_path, venv_path in pairs(cache) do
    if vim.fn.filereadable(venv_path .. "/bin/activate") == 1 then
      table.insert(cached_envs, venv_path)
    end
  end

  -- Build the full choices list
  local choices = {}

  if #local_envs > 0 then
    vim.list_extend(choices, { "--- Project Envs ---" })
    vim.list_extend(choices, local_envs)
  end

  if #cached_envs > 0 then
    vim.list_extend(choices, { "--- Cached Envs ---" })
    vim.list_extend(choices, cached_envs)
  end

  -- Always offer manual entry
  table.insert(choices, "[ Manual Input ]")

  -- If no options at all, warn
  if #choices == 1 then
    vim.notify("No virtual environments found!", vim.log.levels.WARN)
  end

  vim.ui.select(choices, { prompt = "Select VirtualEnv:" }, function(choice)
    if not choice then
      return
    end

    if choice == "--- Manual Input ---" then
      vim.ui.input({ prompt = "Enter full path to virtualenv:" }, function(input)
        if input and vim.fn.isdirectory(input) == 1 and vim.fn.filereadable(input .. "/bin/activate") == 1 then
          vim.env.VIRTUAL_ENV = input
          cache[cwd] = input
          save_venv_cache(cache)
          print("🔀 Switched to manual virtualenv and saved: " .. input)
        else
          vim.notify("Invalid virtualenv path!", vim.log.levels.ERROR)
        end
      end)
    elseif choice:match "^%-%-+" then
      -- If the user selects the "---" separator, ignore
      return
    else
      vim.env.VIRTUAL_ENV = choice
      cache[cwd] = choice
      save_venv_cache(cache)
      print("🔀 Switched to virtualenv and saved: " .. choice)
    end
  end)
end

vim.api.nvim_create_user_command("SwitchVenv", function()
  SwitchVenv()
end, {})

function _G.show_current_venv()
  local venv = vim.env.VIRTUAL_ENV
  local conda_path = vim.env.CONDA_PREFIX
  if venv then
    print("🐍 Current VIRTUAL_ENV: " .. venv)
  elseif conda_path then
    print("🐍 Current CONDA_ENV: " .. conda_path)
  else
    print "❌ No virtualenv active (using system Python)"
  end
end

vim.api.nvim_create_user_command("CurrentVenv", function()
  show_current_venv()
end, {})
