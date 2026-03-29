--=============================================================================
-- config.lua --- git config
-- Copyright (c) 2016-2022 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local job = require('job')

local notify = require('notify')

local log = require('git.log')

local util = require('git.util')

local jobid = -1

local function open_config_buf(len)
  if len > 10 then
    len = 10
  elseif len < 5 then
    len = 5
  end
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
  vim.api.nvim_buf_set_name(bufnr, 'git://config')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_open_win(bufnr, true, {
    split = 'above',
    height = len,
    win = -1,
  })
  vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
  vim.api.nvim_set_option_value('filetype', 'git-config', { buf = bufnr })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
    callback = function()
      vim.cmd('bd!')
    end,
  })
  return bufnr
end

local function on_stdout(id, data)
  if id ~= jobid then
    return
  end

  for _, v in ipairs(data) do
    table.insert(config_stdout, v)
  end
end

local function on_stderr(id, data)
  if id ~= jobid then
    return
  else
    notify.notify(data, { color = 'WarningMsg' })
  end
end

local function on_exit(id, code, signal)
  log.debug(string.format('git-config exit code %d, signal %d', code, signal))
  if id ~= jobid then
    return
  end

  if code == 0 and signal == 0 then
    config_bufid = open_config_buf(#config_stdout)
    util.update_buffer(config_bufid, config_stdout)
  end
end

return {
  run = function(argv)
    local cmd = { 'git', 'config' }

    if #argv == 0 then
      table.insert(cmd, '--list')
    else
      for _, v in ipairs(argv) do
        table.insert(cmd, v)
      end
    end

    log.debug(string.format('git-config cmd: %s', vim.inspect(cmd)))

    jobid = job.start(cmd, {
      on_stdout = on_stdout,
      on_stderr = on_stderr,
      on_exit = on_exit,
    })
  end,
}
