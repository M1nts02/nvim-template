local utils = require "nvim-template.utils"
local path_join = utils.path_join

local M = {}
M.templ_register = {}
M.templ_dir = ""
M.templ_register_file = ""

-- Init
local templ_init = function()
  local file = io.open(M.templ_register_file, "r")

  -- Create register file
  if not file then
    local path = vim.split(M.templ_register_file, "/")
    table.remove(path)
    vim.fn.mkdir(table.concat(path, "/"), "p")
    file = io.open(M.templ_register_file, "w")
    local data = vim.json.encode {}
    file:write(data)
    file:close()
    vim.notify "Not any templates"
  else
    -- Load register file
    M.templ_register = vim.json.decode(file:read "*a")
    file:close()
  end
end

-- Create target
M.create_target = function(templ, target)
  local templ_path = utils.path_join(M.templ_dir, M.templ_register[templ].template)
  target = target ~= nil and target or M.templ_register[templ].target

  local f = io.open(target, "r")
  if f ~= nil then
    io.close(f)
    return target
  end

  -- Create directory for file if necessary
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

-- Add template
M.add_templ = function(templ)
  local templ_name = vim.fn.input "Template File:"
  local templ_path = path_join(M.templ_dir, templ_name)

  -- if template file exist
  local file = io.open(templ_path, "r")
  if file ~= nil then
    vim.notify "Template file exist"
    file:close()
    return
  end

  local target_path = vim.fn.input "Target File:"

  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { templ_path },
    once = true,
    callback = function()
      M.templ_register[templ] = {
        target = target_path,
        template = templ_name,
      }
      local data = vim.json.encode(M.templ_register)
      local register = io.open(M.templ_register_file, "w")
      register:write(data)
      register:close()
    end,
  })

  vim.cmd("e " .. templ_path)
end

-- Delete template
M.del_templ = function(args)
  for _, templ in ipairs(args) do
    if M.templ_register[templ] == nil then
      vim.notify("Unknown template " .. templ)
      goto continue
    end

    local templ_path = utils.path_join(M.templ_dir, M.templ_register[templ].template)
    local result = os.remove(templ_path)

    if result then
      M.templ_register[templ] = nil
      local data = vim.json.encode(M.templ_register)
      local register = io.open(M.templ_register_file, "w")
      register:write(data)
      register:close()
      vim.notify(templ .. " is Deleted")
    else
      vim.notify("False:Delete " .. templ)
    end

    ::continue::
  end
end

-- Complete
M.complete = function(line)
  local templ_list = {}

  -- Add template names for completion
  for i, _ in pairs(M.templ_register) do
    table.insert(templ_list, i)
  end

  -- Return complete
  return vim.tbl_filter(function(val)
    return vim.startswith(val, line)
  end, templ_list)
end

-- Setup
M.setup = function(opts)
  vim.validate { option = { opts, "t" } }
  M.templ_dir = opts.templ_dir or path_join(vim.fn.stdpath "config", "template")
  M.templ_register_file = opts.templ_register_file or path_join(vim.fn.stdpath "config", "template.json")

  templ_init()
end

return M
