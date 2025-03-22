---@param duration number 
---@param title string 
---@param desc string 
---@param type string 
function doNotifyClient(duration, title, desc, type)
  DebugPrint('doNotifyServer: ' .. Config.Notification .. ' ' .. Config.Framework.. desc)
  if Config.Notification == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.Notify(desc, type, duration)
  elseif Config.Notification == 'esx' then
    local ESX = exports["es_extended"]:getSharedObject()
    ESX.ShowNotification(title .. ": " .. desc, type, duration)
  elseif Config.Notification == 'k5' then
    exports["k5_notify"]:notify(type, title, desc, duration)
  elseif Config.Notification == 'okok' then
    exports['okokNotify']:Alert(title, desc, duration, type, false)
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
    TriggerEvent("xs:notify", title, desc, duration, xsType, Config.XSNotifyLocation, 'server')
  else
    lib.notify({
      title = title,
      description = desc,
      type = type,
      duration = duration,
    })
  end
end
exports('doNotifyClient', doNotifyClient)
