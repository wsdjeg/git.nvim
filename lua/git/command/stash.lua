--=============================================================================
-- stash.lua --- :Git stash command
-- Copyright (c) 2016-2024 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')
local util = require('git.util')
local jobid = -1
local show_lines = {}

local function on_stdout(id, data)
  if id ~= jobid then
    return
  end
  nt.notify(table.concat(data, '\n'))
end

local function on_show_stdout(id, data)
  if id ~= jobid then
    return
  end

  for _, v in ipairs(data) do
    table.insert(show_lines, v)
  end
end

local function on_stderr(id, data)
  if id ~= jobid then
    return
  end
  nt.notify(table.concat(data, '\n'), 'WarningMsg')
end

local function on_exit(id, code, signal)
  if id ~= jobid then
    return
  end
  log.debug(string.format('git-stash exit code %d, signal: %d', code, signal))
  if #show_lines > 0 and code == 0 and signal == 0 then
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
    vim.api.nvim_buf_set_name(bufnr, 'git://stash')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
    vim.api.nvim_set_option_value('filetype', 'git-diff', { buf = bufnr })
    vim.api.nvim_set_option_value('syntax', 'diff', { buf = bufnr })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
      callback = function()
        vim.cmd('bd!')
      end,
    })
    util.update_buffer(bufnr, show_lines)
  end
end

local function is_show(cmd)
  for _, v in ipairs(cmd) do
    if v == 'show' then
      return true
    end
  end
  return false
end

function M.run(argv)
  local cmd = { 'git', 'stash' }

  for _, v in ipairs(argv) do
    table.insert(cmd, v)
  end

  log.debug('git-stash cmd:' .. vim.inspect(cmd))
  show_lines = {}

  if is_show(cmd) then
    jobid = job.start(cmd, {
      on_stdout = on_show_stdout,
      on_stderr = on_stderr,
      on_exit = on_exit,
    })
  else
    jobid = job.start(cmd, {
      on_stdout = on_stdout,
      on_stderr = on_stderr,
      on_exit = on_exit,
    })
  end
end

local function sub_commands()
  return {
    'list',
    'show',
    'drop',
    'pop',
    'apply',
    'branch',
    'clear',
    'save',
    'push',
  }
end

function M.complete(ArgLead, CmdLine, CursorPos)
  local str = string.sub(CmdLine, 1, CursorPos)
  if vim.regex([[^Git\s\+stash\s\+[a-z]\+$]]):match_str(str) then
    return vim.tbl_filter(function(t)
      return vim.startswith(t, ArgLead)
    end, sub_commands())
  else
    return {}
  end
end

return M

