local utils = require "nvim-template.utils"
local path_join = utils.path_join

local M = {}
local templ_register = {}

local templ_dir = ""
local templ_register_file = ""

-- Init
local templ_init = function()
  local file = io.open(templ_register_file, "r")

  -- Create register file
  if not file then
    local path = vim.split(templ_register_file, "/")
    table.remove(path)
    vim.fn.mkdir(table.concat(path, "/"), "p")
    file = io.open(templ_register_file, "w")
    local data = vim.json.encode {}
    file:write(data)
    file:close()
    vim.notify "Not any templates"
  else
    -- Load register file
    templ_register = vim.json.decode(file:read "*a")
    file:close()
  end
end

-- TODO: Create target
M.create_target = function(templ, target)
  local templ_path = utils.path_join(templ_dir, templ_register[templ])
  target = target or templ_register.target

  -- Create directory for file if necessary
  if string.sub(target, -1) == "/" or string.sub(target, -1) == "\\" then
    target = target .. templ_register.template
  end
  local p = vim.split(target, "/")
  if #p >= 2 then
    table.remove(p)
    vim.fn.mkdir(table.concat(p, "/"), "p")
  end

  -- Read template
  local old_file, errorString = io.open(templ_path, "rb")
  assert(old_file ~= nil, errorString)
  local data = old_file:read "a"
  old_file:close()

  -- Create target
  local new_file = io.open(target, "wb")
  new_file:write(data)
  new_file:close()

  return target
end

-- TODO: Args analyzer
M.args_analyzer = function(args)
  -- Args number
  if #args > 2 or #args < 1 or type(args) ~= "table" then
    vim.notify_once "Args error"
    return false
  end

  -- Search template
  if templ_register[args[1]] == nil then
    vim.notify_once "Unknown template"
    return false
  end

  -- If target exist
  local f = io.open(args[2], "r")
  if f ~= nil then
    io.close(f)
    vim.notify_once "Target exist"
    return false
  end

  return true
end

-- TODO: Complete
M.complete = function(line)
  local templ_list = {}

  -- Add template names for completion
  for i, _ in pairs(templ_register) do
    table.insert(templ_list, i)
  end

  -- Get args
  local l = vim.split(line, "%s+")

  -- Return complete
  return vim.tbl_filter(function(val)
    return vim.startswith(val, l[2])
  end, templ_list)
end

-- Setup
M.setup = function(opts)
  vim.validate { option = { opts, "t" } }
  templ_dir = opts.temp_dir or path_join(vim.fn.stdpath "config", "template")
  templ_register_file = opts.temp_register_file or path_join(vim.fn.stdpath "config", "template.json")

  templ_init()
end

return M
