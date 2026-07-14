-- test/job.lua
-- Mock job module for testing command modules

local M = {}

local calls = {}
M.start_id = 1

function M.start(cmd, opts)
  local id = M.start_id
  M.start_id = M.start_id + 1
  table.insert(calls, { cmd = cmd, opts = opts, id = id })
  return id
end

function M.send(id, data) end

function M.chanclose(id, type) end

function M.stop(id) end

function M.reset()
  calls = {}
  M.start_id = 1
end

function M.get_calls()
  return calls
end

function M.get_last_call()
  return calls[#calls]
end

function M.get_call_count()
  return #calls
end

return M

