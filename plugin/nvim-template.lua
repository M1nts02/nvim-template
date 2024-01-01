local templ = require "nvim-template"

vim.api.nvim_create_user_command("Template", function(a)
  -- Args analyzer
  local args = vim.split(a.args, " ")
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
  nargs = "*",
  complete = function(_, line)
    local args = vim.split(line, " ")
    templ.complete(args[1])
  end,
})
