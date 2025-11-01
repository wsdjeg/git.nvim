local M = {}

local job = require('job')
local log = require('git.log')
local util = require('git.util')
local show_diff_lines = {}
local jobid = -1

local bufnr = -1

local function on_stdout(id, data)
    if id ~= jobid then
        return
    end
    for _, v in ipairs(data) do
        log.debug('git-show stdout:' .. v)
        table.insert(show_diff_lines, v)
    end
end

local function on_stderr(id, data)
    if id ~= jobid then
        return
    end
    for _, v in ipairs(data) do
        log.debug('git-show stderr:' .. v)
        table.insert(show_diff_lines, v)
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
    vim.cmd([[
    exe 'tabedit git://show'
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setl bufhidden=wipe
    setf git-diff
    setl syntax=diff
  ]])
    bufnr = vim.fn.bufnr()
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
        callback = close_diff_win,
    })
    return bufnr
end

local function on_exit(id, code, single)
    if id ~= jobid then
        return
    end
    log.debug('git-show exit code:' .. code .. ' single:' .. single)
    if #show_diff_lines > 0 then
        bufnr = open_diff_buffer()
        vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, show_diff_lines)
        vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    end
end

function M.run(argv)
    local cmd = { 'git', 'show' }
    for _, v in ipairs(argv) do
        table.insert(cmd, v)
    end
    show_diff_lines = {}
    log.debug('git-show cmd:' .. vim.inspect(cmd))
    jobid = job.start(cmd, {
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
    })
end

return M
