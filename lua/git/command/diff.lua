local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')
local util = require('git.util')
local diff_lines = {}
local jobid = -1

local bufnr = -1

local function on_stdout(id, data)
  if id ~= jobid then
    return
  end
  for _, v in ipairs(data) do
    log.debug('git-diff stdout:' .. v)
    table.insert(diff_lines, v)
  end
end

local function on_stderr(id, data)
  if id ~= jobid then
    return
  end
  for _, v in ipairs(data) do
    log.debug('git-diff stderr:' .. v)
    table.insert(diff_lines, v)
  end
end

local function close_diff_win()
  if util.is_last_win() then
    vim.cmd('bd!')
  else
    vim.cmd('close')
  end
end

local function open_diff_buffer()
  if vim.api.nvim_buf_is_valid(bufnr) then
    return bufnr
  end
  bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
  vim.api.nvim_buf_set_name(bufnr, 'git://diff')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  local position = vim.g.git_diff_position or '10split'
  if position:match('^[0-9]+split$') then
    local height = tonumber(position:match('^[0-9]+'))
    vim.api.nvim_open_win(bufnr, true, {
      split = 'above',
      height = height,
      win = -1,
    })
  else
    vim.api.nvim_set_current_buf(bufnr)
  end
  vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
  vim.api.nvim_set_option_value('filetype', 'git-diff', { buf = bufnr })
  vim.api.nvim_set_option_value('syntax', 'diff', { buf = bufnr })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
    callback = close_diff_win,
  })
  return bufnr
end

local function on_exit(id, code, single)
  if id ~= jobid then
    return
  end
  log.debug('git-diff exit code:' .. code .. ' single:' .. single)
  if #diff_lines > 0 then
    bufnr = open_diff_buffer()
    util.update_buffer(bufnr, diff_lines)
    vim.api.nvim_create_autocmd('BufReadCmd', {
      buffer = bufnr,
      callback = function()
        util.update_buffer(bufnr, diff_lines)
        vim.api.nvim_set_option_value('syntax', 'diff', { buf = bufnr })
      end,
    })
  else
    nt.notify('No Changes!')
  end
end

function M.run(argv)
  local cmd = { 'git', 'diff' }
  if #argv == 1 and argv[1] == '%' then
    table.insert(cmd, vim.fn.expand('%'))
  else
    for _, v in ipairs(argv) do
      table.insert(cmd, v)
    end
  end
  diff_lines = {}
  log.debug('git-dff cmd:' .. vim.inspect(cmd))
  jobid = job.start(cmd, {
    on_stdout = on_stdout,
    on_stderr = on_stderr,
    on_exit = on_exit,
  })
end

return M

