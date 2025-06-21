-- Framework functions are available via the Community Bridge
local Bridge = exports.community_bridge:Bridge()
local rewardItems = Config.RecycleCenter.Rewards
local onDuty = false
local dropoffLocation = nil

-- Initialize the market database when oxmysql is ready
MySQL.ready(function()
  InitMarket()
end)

---@param origin string # location where this is being called
---@param playerId number # player's server id
---@param failedDist number # distance over the allowed limit
local function sendConsoleAlert(origin, playerId, failedDist)
  print(
    '\n^8[CHEATING-ALERT]^7 ' .. origin .. ' Distance Check Failed!',
    '\n^8[CHEATING-ALERT]^7 Player Name: ' .. GetPlayerName(playerId),
    '\n^8[CHEATING-ALERT]^7 ' .. GetPlayerIdentifierByType(playerId, 'license'),
    '\n^8[CHEATING-ALERT]^7 Over Valid Distance By ' .. failedDist .. ' units!'
  )
end
exports('sendConsoleAlert', sendConsoleAlert)

---@param playerId number # Player ID to check
---@param coords vector3 # center coordinates of the check
---@param radius number # radius of check
local function distanceCheck(playerId, coords, radius)
  local ped = GetPlayerPed(playerId)
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

lib.callback.register('cornerstone_recycle:server:getMarketData', function(src)
  return GetMarketData()
end)

RegisterNetEvent('cornerstone_recycle:server:quickSell', function()
  QuickSell(source)
end)

RegisterNetEvent('cornerstone_recycle:server:buyItem', function(item, amount)
  BuyItem(source, item, amount)
end)

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)
