local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')
local util = require('git.util')

local blame_buffer_nr = -1
local blame_show_buffer_nr = -1

local lines = {}
local blame_history = {}

local function on_stdout(_, data)
  for _, v in ipairs(data) do
    log.debug('git-blame stdout:' .. v)
    table.insert(lines, v)
  end
end

local function on_stderr(_, data)
  for _, v in ipairs(data) do
    log.debug('git-blame stderr:' .. v)
    nt.notify(v, 'WarningMsg')
  end
end

local function parser(l)
  local rst = {}
  local obj = {}
  for _, line in ipairs(l) do
    if vim.regex('^[a-zA-Z0-9]\\{40}'):match_str(line) then
      if obj.summary and obj.line then
        table.insert(rst, obj)
      end
      obj = {}
      obj.revision = string.sub(line, 1, 40)
    elseif vim.startswith(line, 'summary') then
      obj.summary = string.sub(line, 9)
    elseif vim.startswith(line, 'filename') then
      obj.filename = string.sub(line, 10)
    elseif vim.startswith(line, 'previous') then
      obj.previous = string.sub(line, 10, 49)
    elseif vim.startswith(line, 'committer-time') then
      obj.time = tonumber(string.sub(line, 15))
    elseif vim.startswith(line, '\t') then
      obj.line = string.sub(line, 2)
    end
  end
  return rst
end

local function open_previous()
  local rst = vim.fn.getbufvar(blame_buffer_nr, 'git_blame_info')
  if vim.fn.empty(rst) == 1 then
    return
  end

  local blame_info = rst[vim.fn.line('.')]
  if blame_info.previous then
    table.insert(blame_history, { blame_info.revision, blame_info.filename })
    vim.cmd('Git blame ' .. blame_info.previous .. ' ' .. blame_info.filename)
  else
    nt.notify('No related parent commit')
  end
end

local function go_back()
  if #blame_history == 0 then
    nt.notify('No navigational history')
    return
  end
  local info = table.remove(blame_history)
  vim.cmd('Git blame ' .. info[1] .. ' ' .. info[2])
end

local function close_blame_show_win()
  if vim.api.nvim_buf_is_valid(blame_show_buffer_nr) then
    vim.cmd('bd ' .. blame_show_buffer_nr)
  end
end

local function close_blame()
  blame_history = {}
  close_blame_show_win()
  vim.cmd('q')
end

local function open_blame_win()
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
  vim.api.nvim_buf_set_name(bufnr, 'git://blame')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_open_win(bufnr, true, {
    split = 'left',
    win = -1,
  })
  vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('scrollbind', true, { win = 0 })
  vim.api.nvim_set_option_value('filetype', 'git-blame', { buf = bufnr })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
  blame_buffer_nr = bufnr
  vim.api.nvim_buf_set_keymap(blame_buffer_nr, 'n', '<Cr>', '', {
    callback = open_previous,
  })
  vim.api.nvim_buf_set_keymap(blame_buffer_nr, 'n', '<BS>', '', {
    callback = go_back,
  })
  vim.api.nvim_buf_set_keymap(blame_buffer_nr, 'n', 'q', '', {
    callback = close_blame,
  })
end

local function generate_context(ls)
  local rst = {}

  for _, v in ipairs(ls) do
    log.debug(vim.inspect(v))
    table.insert(
      rst,
      util.fill(v.summary, 40)
        .. string.rep(' ', 4)
        .. vim.fn.strftime('%Y %b %d %X', v.time)
    )
  end
  return rst
end

local function open_blame_show_win(fname)
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
  vim.api.nvim_buf_set_name(bufnr, 'git://blame:show/' .. fname)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_open_win(bufnr, true, {
    vertical = true,
    split = 'right',
    win = -1,
  })
  vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
  vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  vim.api.nvim_set_option_value('scrollbind', true, { win = 0 })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
    callback = function()
      vim.cmd('bd!')
    end,
  })
  return bufnr
end

local function on_exit(_, code, single)
  log.debug('git-blame exit code:' .. code .. ' single:' .. single)
  if code == 0 and single == 0 then
    local rst = parser(lines)
    -- log.debug(vim.inspect(rst))
    if #rst > 0 then
      if not vim.api.nvim_buf_is_valid(blame_buffer_nr) then
        open_blame_win()
      end
      vim.fn.setbufvar(blame_buffer_nr, 'git_blame_info', rst)
      util.update_buffer(blame_buffer_nr, generate_context(rst))
      local fname = rst[1].filename
      if not vim.api.nvim_buf_is_valid(blame_show_buffer_nr) then
        blame_show_buffer_nr = open_blame_show_win(fname)
      end
      vim.api.nvim_set_option_value(
        'modifiable',
        true,
        { buf = blame_show_buffer_nr }
      )
      local ls = {}
      for _, v in ipairs(rst) do
        table.insert(ls, v.line)
      end
      vim.api.nvim_buf_set_lines(blame_show_buffer_nr, 0, -1, false, ls)
      vim.api.nvim_set_option_value(
        'modifiable',
        false,
        { buf = blame_show_buffer_nr }
      )
    end
  else
    -- local max_w = nt.notify_max_width
    -- nt.notify_max_width = math.floor(vim.o.columns / 2)
    nt.notify(table.concat(lines, '\n'))
    -- nt.notify_max_width = max_w
  end
end

function M.run(argv)
  local cmd = { 'git', 'blame', '--line-porcelain' }
  if #argv == 0 then
    table.insert(cmd, vim.fn.expand('%'))
  else
    for _, v in ipairs(argv) do
      table.insert(cmd, v)
    end
  end
  log.debug('git-blame cmd:' .. vim.inspect(cmd))
  lines = {}
  job.start(cmd, {
    on_stdout = on_stdout,
    on_stderr = on_stderr,
    on_exit = on_exit,
  })
end

return M

