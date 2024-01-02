local templ = require "nvim-template"

vim.api.nvim_create_user_command("Templ", function(opt)
  -- Args analyzer
  local args = {}
  for _, v in ipairs(vim.split(opt.args, " ")) do
    if v ~= "" and v ~= " " then
      table.insert(args, v)
    end
  end

  -- Args number
  if #args > 2 or #args < 1 or args[1] == "" then
    vim.notify "Args error"
    return
  end

  -- Target path
  if args[2] ~= nil then
    if args[2]:sub(-1) == "/" or args[2]:sub(-1) == "\\" then
      vim.notify "Target path error"
      return false
    end
  end

  -- Search template
  if templ.templ_register[args[1]] == nil then
    vim.notify "Unknown template"
    return
  end

  -- Create target file
  local target = templ.create_target(args[1], args[2])

  -- Open target file
  vim.cmd("e " .. target)
end, {
  desc = "Template",
  nargs = "?",
  complete = function(arg, line, pos)
    local args = vim.split(line:sub(1, pos), " ")

    for i, v in ipairs(args) do
      if v == "" then
        table.remove(args, i)
      end
    end

    if #args == 1 or (#args == 2 and arg ~= " " and arg ~= "") then
      return templ.complete(arg)
    end
  end,
})

-- TODO: Create template
--vim.api.nvim_create_user_command("TemplCreate", function(opt)
--  -- Args analyzer
--  local args = {}
--  for _, v in ipairs(vim.split(opt.args, " ")) do
--    if v ~= "" and v ~= " " then
--      table.insert(args, v)
--    end
--  end
--
--  -- Args number
--  if #args ~= 1 then
--    vim.notify "Args error"
--    return
--  end
--
--  -- Search template
--  if templ.templ_register[args[1]] ~= nil then
--    vim.notify "Template exist"
--    return
--  end
--end, {
--  desc = "Create template",
--  nargs = "*",
--})

vim.api.nvim_create_user_command("TemplDel", function(opt)
  local args = {}
  for _, v in ipairs(vim.split(opt.args, " ")) do
    if v ~= "" and v ~= " " then
      table.insert(args, v)
    end
  end

  -- Args number
  if #args < 1 or args == {} or args == nil then
    vim.notify "Args error"
    return
  end

  templ.del_templ(args)
end, {
  desc = "Delete template",
  nargs = "*",
  complete = function(arg)
    return templ.complete(arg)
  end,
})
