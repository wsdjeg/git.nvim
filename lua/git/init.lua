local M = {}

local log = require('git.log')
local util = require('git.util')

local cmds = {
  'add',
  'blame',
  'branch',
  'checkout',
  'config',
  'cherry-pick',
  'clean',
  'commit',
  'diff',
  'fetch',
  'log',
  'merge',
  'mv',
  'pull',
  'push',
  'remote',
  'reset',
  'rm',
  'reflog',
  'shortlog',
  'status',
  'grep',
  'rebase',
  'stash',
  'tag',
  'update-index',
}
local supported_commands = {}

local function update_cmd()
  for _, v in ipairs(cmds) do
    supported_commands[v] = true
  end
end

update_cmd()

function M.run(cmdline)
  -- log.debug('cmdlien:' .. cmdline)

  local argv = util.parser(cmdline)

  -- log.debug('argvs:' .. vim.inspect(argv))

  local command = table.remove(argv, 1)

  if not supported_commands[command] then
    vim.api.nvim_echo({ { ':Git ' .. command .. ' is not supported', 'WarningMsg' } }, false, {})
    return
  end

  local ok, cmd = pcall(require, 'git.command.' .. command)
  if ok then
    if type(cmd.run) == 'function' then
      cmd.run(argv)
    else
      vim.api.nvim_echo(
        { { 'git.command.' .. command .. '.run  is not function', 'WarningMsg' } },
        false,
        {}
      )
    end
  else
    error(cmd)
  end
end

function M.complete(ArgLead, CmdLine, CursorPos)
  local str = string.sub(CmdLine, 1, CursorPos)
  if vim.regex([[^Git\s\+[a-zA-Z]*$]]):match_str(str) then
    return vim.tbl_filter(function(t)
      return vim.startswith(t, ArgLead)
    end, cmds)
  end

  local command = vim.fn.split(CmdLine)[2]

  local ok, cmd = pcall(require, 'git.command.' .. command)
  if ok and type(cmd.complete) == 'function' then
    return cmd.complete(ArgLead, CmdLine, CursorPos)
  end
end

return M
