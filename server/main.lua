if Config.Framework == 'qb' then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'qbx' then QBX = exports.qbx_core end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end

local rewardItems = Config.RecycleCenter.Rewards
local onDuty = false
local dropoffLocation = nil

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
  local player = source
  local ped = GetPlayerPed(player)
  local playerCoords = GetEntityCoords(ped)
  local dist = #(playerCoords - coords)

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

RegisterNetEvent('cornerstone_recycle:server:processDropoff', function()
  if not onDuty then return end
  if not dropoffLocation then return end
  
  local canProcess = distanceCheck(source, dropoffLocation, 5.0)
  if canProcess then
    -- Determine how many items to give from Config.RecycleCenter.Rewards min and max values
    local rewardCnt = math.random(rewardItems.MinRewardItems, rewardItems.MaxRewardItems)
    -- now use the rewardCnt to select that amount for rewards from Config.RecycleCenter.Rewards.Items
    for i = 1, rewardCnt do
      local item = rewardItems.Items[math.random(#rewardItems.Items)]
      DebugPrint(item)
      DebugPrint('Giving player ' .. item.Amount .. ' ' .. item.Item)
      -- determine how many of that item go give the player based on Config.RecycleCenter.Rewards.Items
      addItem(source, item.Item, item.Amount)
    end
    
  else
    sendConsoleAlert('cornerstone_recycle:server:processDropoff', source, 5.0)
  end
  
end)

RegisterNetEvent('cornerstone_recycle:server:registerPickupLocation', function(location)
  dropoffLocation = location
    
end)

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)