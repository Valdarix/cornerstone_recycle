-- Framework functions are provided by the Community Bridge

local recycleCenter = Config.RecycleCenter
local ped = recycleCenter.Ped
local pickLocations = recycleCenter.PickupModels
local pickupObjects = {}

local blip = nil
local onDuty = false

local managerPed = nil
local dropOffObj = nil

local isCarryingPackage = false
local currentPackage = 0

local locationSet = false
local randomLocation = nil
local pickupId = 'pikcupLocation'



local function CleanUpWarehouse()
  -- Cleanup
  Target.RemoveZone('recycle_center_exit')
  Target.RemoveZone('recycle_center_laptop')
  Target.RemoveZone('recycle_center_managerPed')
  Target.RemoveLocalEntity(dropOffObj, 'Sort Recycling')
  Target.RemoveLocalEntity(managerPed)

  if managerPed ~= nil and DoesEntityExist(managerPed) then
    DeleteEntity(managerPed)
  end

  if currentPackage ~= nil and DoesEntityExist(currentPackage) then
    DeleteEntity(currentPackage)
  end

  if dropOffObj ~= nil and DoesEntityExist(dropOffObj) then
    DeleteEntity(dropOffObj)
  end
  if pickupObjects ~= nil then
    for k, v in pairs(pickupObjects) do
      if DoesEntityExist(v) then
        DeleteEntity(v)
      end
    end
  end
  DebugPrint('Cleaned up warehouse')
end

local function DropPackage()
  DebugPrint('Dropping package')
  if currentPackage ~= nil and DoesEntityExist(currentPackage) then
    DeleteEntity(currentPackage)
    currentPackage = 0
    ClearPedTasks(cache.ped)
  end
  isCarryingPackage = false
end

local function ProcessDropoff()
  -- Process Dropoff
  if onDuty and isCarryingPackage then
    DropPackage()   
    isCarryingPackage = false
    currentPackage = 0
    locationSet = false
    TriggerServerEvent('cornerstone_recycle:server:processDropoff')
  end
  doNotifyClient(5000, 'Recycle Center', 'You have sorted this load!', 'success')
end

local function setupDropoffTarget()
  Target.AddLocalEntity(dropOffObj, {
    {
      distance = 1.5,
      name = 'recycle_center_dropoff',
      icon = 'fas fa-recycle',
      label = 'Sort Recycling',
      onSelect = function()
        if isCarryingPackage then
          if currentPackage ~= nil then
            ProcessDropoff()
          end
        else
          doNotifyClient(5000, 'Recycle Center', 'You do not have anything to sort!', 'error')
        end
      end,
    }
  })
end

local function SetupDropoffLocation()
  local dropoffLocation = recycleCenter.DropOff.location
  LoadModel(recycleCenter.DropOff.model)

  dropOffObj = CreateObject(recycleCenter.DropOff.model, dropoffLocation.x, dropoffLocation.y, dropoffLocation.z, false,
    true, true)
  SetEntityHeading(dropOffObj, dropoffLocation.w)
  PlaceObjectOnGroundProperly(dropOffObj)
  FreezeEntityPosition(dropOffObj, true)
  
end

local function GrabPackage(type, location) 

  DebugPrint('Grabbing package: ' .. type .. ' using animagtion and prop')

  local boxModel = `prop_cs_cardbox_01`
  local bagModel = `p_binbag_01_s`
    
  local animDict = ''
  local animName = ''
  local offsetX, offsetY, offsetZ = 0.0, 0.0, 0.0
  local rotX, rotY, rotZ = 0, 0, 0
  currentPackage = 0
  local boneIndex = GetPedBoneIndex(cache.ped, 57005)
  if type == 'prop_recyclebin_04_b' then    
    LoadModel(bagModel)
    currentPackage = CreateObject(bagModel, location.x, location.y, location.z, false, true, true)
    offsetX, offsetY, offsetZ = 0.0, 0.0, 0.0
    rotX, rotY, rotZ = 0, 0, 0  
    animDict = 'anim@heists@narcotics@trash'
    animName = 'idle'
  elseif type == 'prop_boxpile_06b' or type == 'prop_boxpile_01a' or type == 'prop_boxpile_04a' then
    LoadModel(boxModel)
    currentPackage = CreateObject(boxModel, location.x, location.y, location.z, false, true, true)
    offsetX, offsetY, offsetZ = 0.30, -0.07, -0.20
    rotX, rotY, rotZ = -120, 75, -10     
    animDict = 'anim@heists@box_carry@'
    animName = 'idle'
  end
  lib.requestAnimDict(animDict)

  TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)
  AttachEntityToEntity(currentPackage, cache.ped, boneIndex, offsetX, offsetY, offsetZ, rotX, rotY, rotZ, true, true,
    false, true, 1, true)
    setupDropoffTarget()
   
end

local function pickRandomLocation()
  randomLocation = pickLocations[math.random(#pickLocations)]
  pickupId = pickupId ..
  randomLocation.name .. randomLocation.location.x .. randomLocation.location.y .. randomLocation.location.z
  -- convert randomLocation.location to vector3 so it can be passed to server
  local newLocation = vector3(recycleCenter.DropOff.location.x, recycleCenter.DropOff.location.y, recycleCenter.DropOff.location.z)
  TriggerServerEvent('cornerstone_recycle:server:registerPickupLocation', newLocation)
  DebugPrint('Picking up location: ' .. pickupId)
  Target.AddBoxZone(pickupId,
    vector3(randomLocation.location.x, randomLocation.location.y, randomLocation.location.z + 0.5),
    { x = 5.0, y = 5.0, z = 2.0 },
    randomLocation.location.w,
    {
      {
        icon = 'fas fa-hand',
        label = 'Pickup Recycling',
        onSelect = function()
          if not isCarryingPackage then
            isCarryingPackage = true
            doNotifyClient(5000, 'Recycle Center', 'You have picked up a load!', 'success')
            GrabPackage(randomLocation.name, randomLocation.location)
            Target.RemoveZone(pickupId)
          else
            doNotifyClient(5000, 'Recycle Center', 'You are already carrying a load!', 'error')
          end
        end,
        distance = 1.0,
      }
    },
    Config.Debug
  )
  DebugPrint('Added pickup location')
  locationSet = true
end

local function SetupPickLocations()
  for k, v in pairs(pickLocations) do
    LoadModel(v.name)
    local obj = CreateObject(v.name, v.location.x, v.location.y, v.location.z, false, true, true)
    table.insert(pickupObjects, obj)
    SetEntityHeading(obj, v.location.w)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
  end
end

-- Custom NUI based shop interface replacing the ox_lib context menu
local function OpenManagerUI()
  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'open' })
  lib.callback('cornerstone_recycle:server:getMarketData', false, function(data)
    SendNUIMessage({ action = 'setData', data = data })
  end)
end

RegisterNUICallback('close', function(_, cb)
  SetNuiFocus(false, false)
  cb('ok')
end)

RegisterNUICallback('quickSell', function(_, cb)
  TriggerServerEvent('cornerstone_recycle:server:quickSell')
  cb('ok')
end)

RegisterNUICallback('buyItem', function(data, cb)
  TriggerServerEvent('cornerstone_recycle:server:buyItem', data.item, data.amount)
  cb('ok')
end)

RegisterNetEvent('cornerstone_recycle:client:refreshMarket', function()
  lib.callback('cornerstone_recycle:server:getMarketData', false, function(data)
    SendNUIMessage({ action = 'setData', data = data })
  end)
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  CleanUpWarehouse()
end)

local function CreateBlip()
  blip = AddBlipForCoord(recycleCenter.Enter.x, recycleCenter.Enter.y, recycleCenter.Enter.z)
  SetBlipSprite(blip, 365)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.8)
  SetBlipColour(blip, 5)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Recycling Center")
  EndTextCommandSetBlipName(blip)
end

local function ExitWarehouse()
  DebugPrint('Exit Recycling Center')
  onDuty = lib.callback.await('cornerstone_recycle:server:getDutyState')
  DebugPrint('Player is on duty: ' .. tostring(onDuty))
  if not onDuty then
    local playerPed = PlayerPedId()
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetEntityCoords(playerPed, recycleCenter.Enter.x, recycleCenter.Enter.y, recycleCenter.Enter.z, false, false, false,
      false)
    SetEntityHeading(playerPed, recycleCenter.Enter.w)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)

    CleanUpWarehouse()
  else
    doNotifyClient(5000, 'Recycle Center', 'You must go off duty first', 'error')
  end
end

local function ToggleDuty()
  if onDuty then
    onDuty = false
    locationSet = false
    isCarryingPackage = false
    currentPackage = 0
    Target.RemoveZone(pickupId)

    TriggerServerEvent('cornerstone_recycle:server:toggleDuty', false)
    doNotifyClient(5000, 'Recycle Center', 'You are now off duty', 'error')
  else
    onDuty = true    
    doNotifyClient(5000, 'Recycle Center', 'You are now on duty', 'success')
    TriggerServerEvent('cornerstone_recycle:server:toggleDuty', true)
  end
end

local function SetupLaptop()
  Target.AddBoxZone('recycle_center_laptop',
    vector3(recycleCenter.DutyLocation.x, recycleCenter.DutyLocation.y, recycleCenter.DutyLocation.z),
    { x = 1.0, y = 1.0, z = 1.0 },
    recycleCenter.DutyLocation.w,
    {
      {
        icon = 'fas fa-laptop',
        label = 'Toggle Duty',
        onSelect = function()
          ToggleDuty()
        end,
        distance = 1.0,
      }
    },
    Config.Debug
  )
end

local function SetupInterior()
  Target.AddBoxZone('recycle_center_exit',
    recycleCenter.Exit.xyz,
    { x = 5.0, y = 2.0, z = 2.0 },
    recycleCenter.Exit.w,
    {
      {
        icon = 'fas fa-recycle',
        label = 'Exit Recycle Center',
        onSelect = function()
          ExitWarehouse()
        end,
        distance = 2.0,
      }
    },
    Config.Debug
  )
end

local function SetupPed()
  LoadModel(ped.Model)

  managerPed = CreatePed(0, ped.Model, ped.location.x, ped.location.y, ped.location.z - 1, ped.location.w, false, false)

  SetEntityAsMissionEntity(managerPed, true, true)
  SetBlockingOfNonTemporaryEvents(managerPed, true)
  FreezeEntityPosition(managerPed, true)
  SetEntityInvincible(managerPed, true)
  SetEntityHeading(managerPed, ped.location.w)
  Target.AddLocalEntity(managerPed, {
    {
      distance = 1.5,
      name = 'recycle_center_managerPed',
      icon = 'fas fa-comment-dollar',
      label = 'Buy/Sell Items',
      onSelect = function()
        OpenManagerUI()
      end,
    }
  })
end

local function EnterWarehouse()
  DebugPrint('Entered Recycling Center')
  local playerPed = PlayerPedId()
  DoScreenFadeOut(1000)
  Citizen.Wait(1000)
  SetEntityCoords(playerPed, recycleCenter.Exit.x, recycleCenter.Exit.y, recycleCenter.Exit.z, false, false, false, false)
  SetEntityHeading(playerPed, recycleCenter.Exit.w)

  SetupInterior()
  SetupLaptop()
  SetupPed()
  SetupPickLocations()
  SetupDropoffLocation()

  Citizen.Wait(1000)
  DoScreenFadeIn(1000)

end

local function SetupRecycleCenter()
  Target.AddBoxZone('recycle_center_enter',
    recycleCenter.Enter.xyz,
    { x = 5.0, y = 2.0, z = 5.0 },
    recycleCenter.Enter.w,
    {
      {
        icon = 'fas fa-recycle',
        label = 'Enter Recycle Center',
        onSelect = function()
          EnterWarehouse()
        end,
        distance = 2.0,
      },
    },
    Config.Debug
  )

  
end


Citizen.CreateThread(function()
  CreateBlip()
  SetupRecycleCenter()
  while true do
    Citizen.Wait(500)
    if onDuty and not isCarryingPackage and not locationSet then
      DebugPrint('Picking random location')
      pickRandomLocation()
    end
  end
end)


Citizen.CreateThread(function()
  while true do
    if onDuty and locationSet and randomLocation ~= nil and not isCarryingPackage then
      DrawMarker(3, randomLocation.location.x, randomLocation.location.y, randomLocation.location.z + 3.0,
      0, 0, 0, 180.0, 0, 0, 1.25, 1.25, 1.25, 255, 0, 0, 100, false, false, 2, true, nil, nil, false)
      Citizen.Wait(1)
    else
      Citizen.Wait(250)
    end
  end
end)
