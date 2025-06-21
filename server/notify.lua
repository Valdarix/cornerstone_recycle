local Bridge = exports.community_bridge:Bridge()
-- Notifications are handled through the Community Bridge
-- which provides a universal wrapper for multiple
-- frameworks and notification resources.

---@param src number # player source
---@param duration number # Length of noti
---@param title string # noti title can be empty string for qb
---@param desc string # noti desc
---@param type string # success or error
function doNotifyServer(src, duration, title, desc, type)
  DebugPrint('doNotifyServer via Community Bridge')
  Bridge.Notify.SendNotify(src, title .. ' ' .. desc, type, duration)
end
exports('doNotify', doNotify)
