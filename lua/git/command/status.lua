local M = {}

local job = require('job')
local log = require('git.log')

local status_bufnr = -1
local lines = {}

local jobid = -1

local function close_status_window()
    if vim.fn.winnr('$') > 1 then
        vim.cmd('close')
    else
        vim.cmd('bd!')
    end
end

local function openStatusBuffer()
    status_bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(status_bufnr, 'git://status')
    vim.api.nvim_buf_set_lines(status_bufnr, 0, -1, false, {})
    local winid = vim.api.nvim_open_win(status_bufnr, true, {
        split = 'above',
        height = 10,
    })
    vim.api.nvim_set_option_value('buflisted', false, { buf = status_bufnr })
    vim.api.nvim_set_option_value('modifiable', false, { buf = status_bufnr })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = status_bufnr })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = status_bufnr })
    vim.api.nvim_set_option_value('filetype', 'git-status', { buf = status_bufnr })
    vim.api.nvim_set_option_value('number', false, { win = winid })
    vim.api.nvim_set_option_value('relativenumber', false, { win = winid })
    -- nnoremap <buffer><silent> q :call <SID>close_status_window()<CR>
    vim.api.nvim_buf_set_keymap(status_bufnr, 'n', 'q', '', {
        callback = close_status_window,
    })
    return status_bufnr
end

local function on_stdout(id, data)
    if id ~= jobid then
        return
    end
    for _, v in ipairs(data) do
        log.debug('git-status stdout:' .. v)
        table.insert(lines, v)
    end
end

local function on_stderr(id, data)
    if id ~= jobid then
        return
    end
    for _, v in ipairs(data) do
        log.debug('git-status stderr:' .. v)
        table.insert(lines, v)
    end
end

local autocmd
local function on_exit(id, code, single)
    if id ~= jobid then
        return
    end
    log.debug('git-status exit code:' .. code .. ' single:' .. single)
    if vim.api.nvim_buf_is_valid(status_bufnr) then
        vim.api.nvim_set_option_value('modifiable', true, { buf = status_bufnr })
        vim.api.nvim_buf_set_lines(status_bufnr, 0, -1, false, lines)
        vim.api.nvim_set_option_value('modifiable', false, { buf = status_bufnr })
        pcall(vim.api.nvim_del_autocmd, autocmd)
        autocmd = vim.api.nvim_create_autocmd('BufReadCmd', {
            buffer = status_bufnr,
            callback = function()
                vim.api.nvim_set_option_value('modifiable', true, { buf = status_bufnr })
                vim.api.nvim_buf_set_lines(status_bufnr, 0, -1, false, lines)
                vim.api.nvim_set_option_value('modifiable', false, { buf = status_bufnr })
                vim.api.nvim_set_option_value('syntax', 'diff', { buf = status_bufnr })
            end,
        })
    end
end

function M.run(argv)
    if
        vim.api.nvim_buf_is_valid(status_bufnr)
        and vim.fn.index(vim.fn.tabpagebuflist(), status_bufnr) ~= -1
    then
        local winnr = vim.fn.bufwinnr(status_bufnr)
        vim.cmd(winnr .. 'wincmd w')
    else
        status_bufnr = openStatusBuffer()
    end
    local cmd = { 'git', 'status' }
    if #argv > 0 then
        for _, v in ipairs(argv) do
            table.insert(cmd, v)
        end
    end
    lines = {}
    log.debug('git-status cmd:' .. vim.inspect(cmd))
    jobid = job.start(cmd, {
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
    })
end

return M
