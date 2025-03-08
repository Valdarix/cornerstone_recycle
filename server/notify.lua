---@param src number # player source
---@param duration number # Length of noti
---@param title string # noti title can be empty string for qb
---@param desc string # noti desc
---@param type string # success or error
function doNotify(src, duration, title, desc, type)
  if Config.Notification == 'qb' then
    TriggerClientEvent('QBCore:Notify', src, title .. ' ' .. desc, type, duration)
  elseif Config.Notification == 'esx' then
    TriggerClientEvent('esx:showNotification', src, title .. ' ' .. desc, type, duration)
  elseif Config.Notification == 'k5' then
    TriggerClientEvent("k5_notify:notify", src, 'Notification', title, desc, duration)
  elseif Config.Notification == 'okok' then    
    TriggerClientEvent('okokNotify:Alert', src, title, desc, duration, type, false)
  elseif Config.Notification == 'xs' then
    local xsType = 0
    if type == 'error' then
      xsType = 0
    elseif type == 'success' then
      xsType = 1
    elseif type == 'warning' then
      xsType = 2
    elseif type == 'information' then
      xsType = 3
    end
    TriggerClientEvent("xs:notify", src, title, desc, duration, xsType, Config.XSLocation, 'server')    
  else
    TriggerClientEvent('ox_lib:notify', src, {
      title = title,
      description = desc,
      type = type,
      duration = duration,
      showDuration = true,
    })
  end
end
exports('doNotify', doNotify)
