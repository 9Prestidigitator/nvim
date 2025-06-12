local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

-- This script adds a little more spport for Python virtual environment management

local venv_cache_file = vim.fn.stdpath "data" .. "/venv_cache.json"

local function load_venv_cache()
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

local function get_conda_env_dirs()
  local conda_envs = {}
  local conda_envs_path = os.getenv "CONDA_ENVS_PATH" or (os.getenv "HOME" .. "/miniconda3/envs")
  local handle = vim.loop.fs_scandir(conda_envs_path)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == "directory" then
        table.insert(conda_envs, conda_envs_path .. "/" .. name)
      end
    end
  end
  return conda_envs
end

local function find_project_envs()
  local cwd = vim.fn.getcwd()
  local envs = {}
  local handle = vim.loop.fs_scandir(cwd)
  if not handle then
    return envs
  end
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "directory" and name:match "[Vv]env" then
      local path = cwd .. "/" .. name
      if vim.fn.filereadable(path .. "/bin/activate") == 1 then
        table.insert(envs, path)
      end
    end
  end
  return envs
end

local function switch_venv_with_telescope()
  local cwd = vim.fn.getcwd()
  local venv_cache = load_venv_cache()

  local items = {}
  local env_map = {}

  -- Add cached env
  if venv_cache[cwd] then
    local label = "cached (" .. venv_cache[cwd] .. ")"
    table.insert(items, label)
    env_map[label] = venv_cache[cwd]
  end

  -- Project-local envs
  for _, path in ipairs(find_project_envs()) do
    table.insert(items, "project (" .. path .. ")")
    env_map["project (" .. path .. ")"] = path
  end

  -- Conda envs
  for _, path in ipairs(get_conda_env_dirs()) do
    table.insert(items, "conda (" .. path .. ")")
    env_map["conda (" .. path .. ")"] = path
  end

  if #items == 0 then
    vim.notify("No virtual environments found", vim.log.levels.WARN)
    return
  end

  pickers
    .new({
      layout_strategy = "center",
      layout_config = {
        width = 0.6,
        height = 0.5,
      },
    }, {
      prompt_title = "Select Python Virtual Environment",
      finder = finders.new_table {
        results = items,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local chosen_path = env_map[selection[1]]
          if chosen_path then
            vim.env.VIRTUAL_ENV = chosen_path
            venv_cache[cwd] = chosen_path
            save_venv_cache(venv_cache)
            print("🐍 Switched to: " .. chosen_path)
          else
            vim.notify("Invalid selection", vim.log.levels.ERROR)
          end
        end)
        return true
      end,
    })
    :find()
end

vim.api.nvim_create_user_command("SwitchVenv", function()
  switch_venv_with_telescope()
end, {})

-- Function to display the current virtual environment
local function show_current_venv()
  local venv = vim.env.VIRTUAL_ENV or os.getenv "CONDA_PREFIX"
  if venv then
    print("🐍 Current virtual environment: " .. venv)
  else
    print "❌ No virtual environment active."
  end
end

vim.api.nvim_create_user_command("CurrentVenv", function()
  show_current_venv()
end, {})

local python_term_bufnr = nil
-- Run Python Script
vim.keymap.set("n", "<leader>rr", function()
  local file = vim.fn.expand "%:p"
  local name = vim.fn.expand "%"
  local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"

  if not name:match "%.py" then
    vim.notify("Not a python file!", vim.log.levels.ERROR)
    return
  end
  -- If no terminal exists yet, open one
  if not (python_term_bufnr and vim.api.nvim_buf_is_valid(python_term_bufnr)) then
    vim.cmd "botright split | resize 15 | terminal"
    python_term_bufnr = vim.api.nvim_get_current_buf()
    python_term_chanid = vim.b.terminal_job_id -- Store the terminal's channel ID!
  end
  -- Safety check: make sure channel ID is valid
  if not python_term_chanid then
    vim.notify("No terminal job available!", vim.log.levels.ERROR)
    return
  end

  -- Build the command to run
  local cmd
  if venv then
    cmd = "source " .. venv .. "/bin/activate && python " .. file .. "\n"
  else
    cmd = "python " .. file .. "\n"
  end

  -- Send the command into the stored terminal channel
  vim.fn.chansend(python_term_chanid, cmd)
  -- Return to normal mode
  vim.cmd "stopinsert"
end, { desc = "Run focused Python script" })

