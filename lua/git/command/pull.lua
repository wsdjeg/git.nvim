--=============================================================================
-- pull.lua --- Git pull command
-- Copyright (c) 2016-2023 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================
local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')
local conflict_files = {}

local status = ''

local ok, spinners = pcall(require, 'plugin-utils.unicode.spinners')
local function update_icon(t)
    vim.cmd.redrawstatus()
    status = t
end

local s

function M.status()
    return status
end
local function on_stdout(id, data)
    for _, v in ipairs(data) do
        log.debug('git-pull stdout:' .. v)
        if vim.startswith(v, 'CONFLICT (content): Merge conflict in') then
            table.insert(conflict_files, string.sub(v, 39))
        end
    end
end

local function on_stderr(id, data)
    for _, v in ipairs(data) do
        log.debug('git-pull stderr:' .. v)
    end
end

local function list_conflict_files()
    if #conflict_files > 0 then
        local rst = {}
        for _, file in ipairs(conflict_files) do
            table.insert(rst, {
                filename = vim.fn.fnamemodify(file, ':p'),
            })
        end
        vim.fn.setqflist({}, 'r', { title = ' ' .. #rst .. ' items', items = rst })
        vim.cmd('botright copen')
    end
end

local function on_exit(id, code, single)
    if ok then
        s:stop()
        status = ''
        vim.cmd.redrawstatus()
    end
    log.debug('git-pull exit code:' .. code .. ' single:' .. single)
    if code == 0 and single == 0 then
        nt.notify('pulled done!')
    else
        list_conflict_files()
        nt.notify('pulled failed!')
    end
end

function M.run(argv)
    local cmd = { 'git', 'pull' }
    for _, v in ipairs(argv) do
        table.insert(cmd, v)
    end
    log.debug('git-pull cmd:' .. vim.inspect(cmd))
    if ok then
        s = spinners:new(update_icon)
        s:start()
    end
    job.start(cmd, {
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
    })
end

return M
