local Bridge = exports.community_bridge:Bridge()
---@param duration number 
---@param title string 
---@param desc string 
---@param type string 
function doNotifyClient(duration, title, desc, type)
  DebugPrint('doNotifyClient via Community Bridge')
  Bridge.Notify.SendNotify(title .. ': ' .. desc, type, duration)
end
exports('doNotifyClient', doNotifyClient)
