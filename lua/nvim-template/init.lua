local utils = require "nvim-template.utils"
local path_join = utils.path_join

local M = {}
M.templ_register = {}
M.templ_dir = ""
M.templ_register_file = ""

local author = ""
local email = ""
local git_info = false

-- Init
local function templ_init()
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

local function get_git_info()
  local au = io.popen("git config --get user.name"):read "l"
  local em = io.popen("git config --get user.email"):read "l"
  if au == nil or au == "" or em == "" or em == nil then
    au = author
    em = email
    vim.notify "Can't get git information"
  end
  return au, em
end

-- Create target
function M.create_target(templ, target)
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

  local au = author
  local em = email
  if git_info == true then
    au, em = get_git_info()
  end

  data = string.gsub(data, "${_AUTHOR_}", au)
  data = string.gsub(data, "${_EMAIL_}", em)

  --local p, _ = string.find(data, "${_CURSOR_}")
  --data = string.gsub(data, "${_CURSOR_}", "")

  -- DATE: ${_DATE()_}
  data, _ = string.gsub(data, "${_DATE(.-)_}", function(s)
    return os.date(s:sub(2, -2))
  end)

  -- Create target
  local new_file = io.open(target, "wb")
  new_file:write(data)
  new_file:close()

  return target
end

-- Add template
function M.add_templ(templ)
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
function M.del_templ(args)
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

-- Edit template
-- function M.edit_templ (args)
--   for _, templ in ipairs(args) do
--     if M.templ_register[templ] == nil then
--       vim.notify("Unknown template " .. templ)
--       goto continue
--     end
--
--     local templ_path = utils.path_join(M.templ_dir, M.templ_register[templ].template)
--
--     vim.cmd("e " .. templ_path)
--     ::continue::
--   end
-- end

-- Complete
function M.complete(line)
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
function M.setup(opts)
  vim.validate { option = { opts, "t" } }
  M.templ_dir = opts.templ_dir or path_join(vim.fn.stdpath "config", "template")
  M.templ_register_file = opts.templ_register_file or path_join(vim.fn.stdpath "config", "template.json")

  author = opts.author or author
  email = opts.email or email
  git_info = opts.git_info or git_info

  templ_init()
end

return M
