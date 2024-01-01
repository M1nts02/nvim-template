local templ = require "nvim-template"

vim.api.nvim_create_user_command("Templ", function(opt)
  -- Args analyzer
  local args = {}
  for _, v in ipairs(vim.split(opt.args, " ")) do
    if v ~= "" and v ~= " " then
      table.insert(args, v)
    end
  end

  -- Args analyzer
  local result = templ.args_analyzer(args)
  -- Args error
  if result == false then
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
