local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')
local branch = require('git.command.branch')
local branch_ui = require('git.ui.branch')

local function on_exit(id, code, single)
  log.debug('git-checkout exit code:' .. code .. ' single:' .. single)
  if code == 0 and single == 0 then
    vim.cmd('silent! checktime')
    branch.detect()
    branch_ui.update()
    nt.notify('checkout done.')
  else
    nt.notify('checkout failed.', 'WarningMsg')
  end
end

function M.run(argv)
  local cmd = { 'git', 'checkout' }
  for _, v in ipairs(argv) do
    table.insert(cmd, v)
  end
  log.info('git checkout cmd:' .. vim.inspect(cmd))
  job.start(cmd, { on_exit = on_exit })
end

function M.complete(arglead, cmdline, cursorpos)
  if vim.startswith(arglead, '-') then
    return table.concat({ '-b', '-m' }, '\n')
  end
  local branchs = vim.fn.systemlist('git branch')
  return
    vim.tbl_map(
    function(t)
      return vim.fn.trim(t)
    end,
    vim.tbl_filter(function(t)
      return not vim.startswith(t, '*')
    end, branchs)
  )
end

return M
