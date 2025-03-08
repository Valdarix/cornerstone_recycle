if Config.Framework == 'qb' then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'qbx' then QBX = exports.qbx_core end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end
if Config.Framework == 'nd' then ND = exports["ND_Core"] end

local rewardItems = Config.RecycleCenter.Rewards
local onDuty = false

---@param orgin string # orgin where this is being called
---@param playerId number # center of check
---@param faildDist number # how bad they failed the check
local function sendConsoleAlert(orgin, playerId, faildDist)
  print(
    '\n^8[CHEATING-ALERT]^7 ' .. orgin .. ' Distance Check Failed!',
    '\n^8[CHEATING-ALERT]^7 Player Name: ' .. GetPlayerName(playerId),
    '\n^8[CHEATING-ALERT]^7 ' .. GetPlayerIdentifierByType(playerId, 'license'),
    '\n^8[CHEATING-ALERT]^7 Over Vaild Distance By ' .. faildDist .. ' units!'
  )
end
exports('sendConsoleAlert', sendConsoleAlert)

---@param playerId number # Player Id To Check
---@param coords vector3 # center of check
---@param radius number # radius of check
local function distanceCheck(playerId, coords, radius)
  local dist = #(GetEntityCoords(GetPlayerPed(playerId)) - coords)

  if dist > radius then
    return false
  else
    return true
  end
end
exports('distanceCheck', distanceCheck)


lib.callback.register('cornerstone_recycle:server:getDutyState', function(source)
  return onDuty
end)

RegisterNetEvent('cornerstone_recycle:server:toggleDuty', function (dutyState)
  if dutyState then
    onDuty = true
    DebugPrint('Player is now on duty')
  else
    onDuty = false
    DebugPrint('Player is now off duty')
  end
end)


AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)