if Config.Framework == 'qb' or Config.Framework == 'qbx' then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end

---@param duration number # Length of noti
---@param title string # noti title can be empty string for qb
---@param desc string # noti desc
---@param type string # success or error
local function doNotify(duration, title, desc, type)
  if Config.Notification == 'qb' then
    QBCore.Functions.Notify(title .. ": " .. desc, type, duration)
  elseif Config.Notification == 'esx' then
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
    TriggerEvent("xs:notify", title, desc, duration, xsType, Config.XSLocation, 'server')
  else
    lib.notify({
      title = title,
      description = desc,
      type = type,
      duration = duration,
    })
  end
end
exports('doNotify', doNotify)
