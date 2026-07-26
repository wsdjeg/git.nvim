--=============================================================================
-- restore.lua --- Git restore command
-- Copyright (c) 2016-2025 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')

local function on_exit(_, code, single)
  log.debug('git-restore exit code:' .. code .. ' single:' .. single)
  if code == 0 and single == 0 then
    vim.cmd('silent! checktime')
    if vim.fn.exists(':GitGutter') == 2 then
      vim.cmd('GitGutter')
    end
    nt.notify('git restore done!')
  else
    nt.notify('git restore failed!', 'WarningMsg')
  end
end

function M.run(argv)
  local cmd = { 'git', 'restore' }
  for _, v in ipairs(argv) do
    if v == '%' then
      table.insert(cmd, vim.fn.expand('%'))
    else
      table.insert(cmd, v)
    end
  end
  log.debug('git-restore cmd:' .. vim.inspect(cmd))
  job.start(cmd, {
    on_exit = on_exit,
  })
end

function M.complete(ArgLead, CmdLine, CursorPos)
  return vim.fn.getcompletion(ArgLead, 'file')
end

return M

