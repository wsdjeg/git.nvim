--=============================================================================
-- fetch.lua --- Git fetch
-- Copyright 2023 Eric Wong
-- Author: Eric Wong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')
local stddata = {}

local function on_exit(id, code, single)
  log.debug('git-fetch exit code:' .. code .. ' single:' .. single)
  if code == 0 and single == 0 then
    nt.notify('fetch done!')
  else
    nt.notify(table.concat(stddata, '\n'), 'warningmsg')
  end
end

local function on_std(id, data)
  for _, v in ipairs(data) do
    table.insert(stddata, v)
  end
end

function M.run(argv)
  local cmd = { 'git', 'fetch' }
  for _, v in ipairs(argv) do
    table.insert(cmd, v)
  end
  log.debug('git-fetch cmd:' .. vim.inspect(cmd))
  stddata = {}
  job.start(cmd, {
    on_exit = on_exit,
    on_stdout = on_std,
    on_stderr = on_std,
  })
end

local function get_remotes()
  return vim.tbl_map(function(t)
    return vim.fn.trim(t)
  end, vim.fn.systemlist('git remote'))
end

local options =
  { '--prune', '--prune-tags', '--no-tags', '--tags', '--all', '--multiple' }

function M.complete(ArgLead, CmdLine, CursorPos)
  if vim.startswith(ArgLead, '-') then
    return vim.tbl_filter(function(t)
      return vim.startswith(t, ArgLead)
    end, options)
  end

  local str = string.sub(CmdLine, 1, CursorPos)
  if vim.regex([[^Git\s\+fetch\s\+[^ ]*$]]):match_str(str) then
    return vim.tbl_filter(function(t)
      return vim.startswith(t, ArgLead)
    end, get_remotes())
  else
    return {}
  end
end

return M
