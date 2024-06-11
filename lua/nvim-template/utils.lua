local M = {}

local os_name = jit.os
M.is_mac = os_name:find "OSX" ~= nil
M.is_linux = os_name:find "Linux" ~= nil
M.is_windows = os_name:find "Windows" ~= nil

-- connect path
function M.path_join(...)
  local sep = M.is_windows and "\\" or "/"
  return table.concat({ ... }, sep)
end

return M
