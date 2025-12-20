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

local config_bufid = -1

local config_stdout = {}

local function open_config_buf(len)
    if len > 10 then
        len = 10
    elseif len < 5 then
        len = 5
    end
    vim.cmd(len .. 'split git://config')

    vim.cmd([[
    normal! "_dd
    setl nobuflisted
    setl nomodifiable
    setl nonumber norelativenumber
    setl buftype=nofile
    setf git-config
    nnoremap <buffer><silent> q :bd!<CR>
  ]])
    return vim.api.nvim_get_current_buf()
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
