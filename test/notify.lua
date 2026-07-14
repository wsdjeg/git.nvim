-- test/notify.lua
-- Mock notify module for testing command modules

local M = {}

local notifications = {}
M.notify_max_width = 0
M.timeout = 0

function M.notify(msg, highlight)
  table.insert(notifications, { msg = msg, highlight = highlight })
end

function M.reset()
  notifications = {}
end

function M.get_notifications()
  return notifications
end

function M.get_last_notification()
  return notifications[#notifications]
end

return M

