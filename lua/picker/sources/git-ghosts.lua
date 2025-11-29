local M = {}

local util = require('picker.util')
local job

function M.enabled()
    local ok
    ok, job = pcall(require, 'job')
    if not ok then
        util.notify('async_files source require wsdjeg/job.nvim')
    end
    return ok
end

---@type PickerItem[]
local items = {}

local cmd = { 'git', 'log', '--diff-filter=D', '--summary' }

function M.set()
    items = {}
    local re = vim.regex(' delete mode 100644 ')
    job.start(cmd, {
        on_stdout = function(id, data)
            for _, line in ipairs(data) do
                if re:match_str(line) then
                    local fs = vim.split(line, '%s')
                    local f = fs[#fs]
                    table.insert(items, {
                        value = f,
                        str = f,
                    })
                end
            end
        end,
        on_exit = function(id, data, single)
            require('picker.windows').handle_prompt_changed()
        end,
    })
end

function M.get()
    return items
end

function M.default_action(entry)
    local hash = vim.system({ 'git', 'log', '-1', '--pretty=%H', '--', entry.str }):wait().stdout

    vim.cmd('Git show ' .. hash)
end

return M

