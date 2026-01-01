local M = {}

local ck = require('git.command.checkout')

function M.get()
  return vim.tbl_map(function(t)
    return { value = t, str = t }
  end, ck.complete(''))
end

function M.default_action(selected)
  vim.cmd('Git checkout ' .. selected.value)
end

M.preview_win = false

return M
