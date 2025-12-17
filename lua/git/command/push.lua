local M = {}

local job = require('job')
local nt = require('notify')
local log = require('git.log')

local push_jobid = -1
local stderr_data = {}

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
    if id ~= push_jobid then
        return
    end
    for _, line in pairs(data) do
        nt.notify_max_width = vim.fn.max({ vim.fn.strwidth(line) + 5, nt.notify_max_width })
        nt.notify(line)
    end
end

local function on_stderr(id, data)
    if id ~= push_jobid then
        return
    end
    for _, line in pairs(data) do
        table.insert(stderr_data, line)
    end
end

local function on_exit(id, code, single)
    if ok then
        s:stop()
        status = ''
        vim.cmd.redrawstatus()
    end
    log.debug('push code:' .. code .. ' single:' .. single)
    if id ~= push_jobid then
        return
    end
    if code == 0 and single == 0 then
        for _, line in ipairs(stderr_data) do
            nt.notify(line)
        end
    else
        for _, line in ipairs(stderr_data) do
            nt.notify(line, 'WarningMsg')
        end
    end
    push_jobid = -1
end

function M.run(argv)
    if push_jobid ~= -1 then
        nt.notify('previous push not finished')
    end

    nt.notify_max_width = vim.fn.float2nr(vim.o.columns * 0.3)

    stderr_data = {}

    local cmd = { 'git', 'push' }

    if argv then
        for _, v in ipairs(argv) do
            table.insert(cmd, v)
        end
    end
    log.debug(vim.inspect(cmd))
    if ok then
        s = spinners:new(update_icon)
        s:start()
    end
    push_jobid = job.start(cmd, {
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
    })

    if push_jobid == -1 then
        nt.notify('`git` is not executable')
    end
end

local options = { '-u', '--set-upstream', '-d', '--delete' }

local function remotes()
    return vim.tbl_map(function(t)
        return vim.fn.trim(t)
    end, vim.fn.systemlist('git remote'))
end

local function remote_branch(r)
    local branchs = vim.tbl_filter(
        function(t)
            return #t > 0
        end,
        vim.tbl_map(function(t)
            return vim.trim(t)
        end, vim.split(
            vim.system({ 'git', 'branch', '-a' }, { text = true }):wait().stdout,
            '\n'
        ))
    )
    local rst = {}

    for _, v in ipairs(branchs) do
        if v:find(' -> ') then
            -- do nothing
        elseif vim.startswith(v, 'remotes/' .. r) then
            local branch = string.sub(v, 10 + #r)
            if not vim.tbl_contains(rst, branch) then
                table.insert(rst, branch)
            end
        elseif vim.startswith(v, '* ') then
            table.insert(rst, string.sub(v, 3))
        end
    end
    return rst
end

function M.complete(ArgLead, CmdLine, CursorPos)
    local str = string.sub(CmdLine, 1, CursorPos)
    if vim.regex([[^Git\s\+push\s\+-$]]):match_str(str) then
        return vim.tbl_filter(function(opt)
            return vim.startswith(opt, ArgLead)
        end, options)
    elseif
        vim.regex([[^Git\s\+push\s\+[^ ]*$]]):match_str(str)
        or vim.regex([[^Git\s\+push\s\+-u\s\+[^ ]*$]]):match_str(str)
    then
        return vim.tbl_filter(function(r)
            return vim.startswith(r, ArgLead)
        end, remotes())
    else
        local remote = vim.fn.matchstr(str, [[\(Git\s\+push\s\+-u\s\+\)\@<=[^ ]*]])
        return vim.tbl_filter(function(t)
            return vim.startswith(t, ArgLead)
        end, remote_branch(remote))
    end
end

return M
