if Config.Framework == 'qb' or Config.Framework == 'qbx' then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end
if Config.Framework == 'qbx' then QBX = exports.qbx_core end
if Config.Framework == 'nd' then ND = exports["ND_Core"] end

local recycleCenter = Config.RecycleCenter
local ped = recycleCenter.Ped
local pickLocations = recycleCenter.PickupModels
local pickupObjects = {}

local blip = nil
local onDuty = false

local managerPed = nil
local dropOffObj = nil

local isCarryingPackage = false
local currentPackage = nil
local locationSet = false


local function CleanUpWarehouse()
  -- Cleanup
  if Config.UseTarget then
    if Config.Target == 'ox' then
      exports.ox_target:removeZone('recycle_center_exit')
      exports.ox_target:removeZone('recycle_center_laptop')
      exports.ox_target:removeZone('recycle_center_managerPed')
      exports.ox_target:removeZone('recycle_center_dropoff')      
      
    end
  end

  if managerPed ~= nil and DoesEntityExist(managerPed) then
    DeleteEntity(managerPed)    
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

local function pickRandomLocation()
  local randomLocation = pickLocations[math.random(#pickLocations)]
  DebugPrint('Picking up location: ' .. randomLocation.name)
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = { randomLocation.location.x, randomLocation.location.y, randomLocation.location.z + 1.0 },
        name = 'recycle_center_pickup',
        heading = randomLocation.location.w,
        debug = Config.Debug,
        minZ = randomLocation.location.z,
        maxZ = randomLocation.location.z + 1.0,
        options = {
          {
            onSelect = function()
              if not isCarryingPackage then
                isCarryingPackage = true
                currentPackage = randomLocation
                doNotifyClient(5000, 'Recycle Center', 'You have picked up a load!', 'success')
                exports.ox_target:removeZone('recycle_center_pickup')
              else
                doNotifyClient(5000, 'Recycle Center', 'You are already carrying a load!', 'error')
              end
            end,
            icon = 'fas fa-hand',
            label = 'Pickup Recycling',
            distance = 2.0,
          },
        },
      }
      exports.ox_target:addBoxZone(parameters)
      DebugPrint('Added pickup location')
    end
  end
  locationSet = true
end

local function ProcessDropoff()
  -- Process Dropoff   
  isCarryingPackage = false
  currentPackage = nil
  locationSet = false
  if onDuty and not locationSet then    
    if not isCarryingPackage then      
      pickRandomLocation()
    end
   
  end
  doNotifyClient(5000, 'Recycle Center', 'You have sorted this load!', 'success')
end

local function SetupDropoffLocation()
  local dropoffLocation = recycleCenter.DropOff.location
  LoadModel(recycleCenter.DropOff.model)
  
  dropOffObj = CreateObject(recycleCenter.DropOff.model, dropoffLocation.x, dropoffLocation.y, dropoffLocation.z, false, true, true)
  SetEntityHeading(dropOffObj, dropoffLocation.w)
  PlaceObjectOnGroundProperly(dropOffObj)
  FreezeEntityPosition(dropOffObj, true)

 if Config.UseTarget then
  if Config.Target == 'ox' then
    local parameters = {
      coords = { dropoffLocation.x, dropoffLocation.y, dropoffLocation.z + 1.0 },
      name = 'recycle_center_dropoff',
      heading = dropoffLocation.w,
      debug = Config.Debug,
      minZ = dropoffLocation.z,
      maxZ = dropoffLocation.z + 1.0,
      options = {
        {
          onSelect = function()
            if isCarryingPackage then
              if currentPackage ~= nil then
                ProcessDropoff()
              end
            else
              doNotifyClient(5000, 'Recycle Center', 'You do not have anything to sort!', 'error')
            end
          end,
          icon = 'fas fa-recycle',
          label = 'Sort Recycling',
          distance = 2.0,
        },
      },
    }
    exports.ox_target:addBoxZone(parameters)
  end
end
  
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

local function SetupContextMenu()
  lib.registerContext({
    id = 'recycle_manger_menu',
    title = 'Recycling Shop',
    options = {
      {
        title = 'Sell Materials',
        description = 'Sell your gathered materials.',
        icon = 'fas fa-money-bill-wave',

      },
      {
        title = 'Buy Materials',
        description = 'Buy excess materials',
        icon = 'fab fa-shopify',
        onSelect = function()
          print("Pressed the button!")
        end,
        metadata = {
          { label = 'Value 1', value = 'Some value' },
          { label = 'Value 2', value = 300 }
        },
      },
    }
  })
end

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
    exports.ox_target:removeZone('recycle_center_pickup')
    
    TriggerServerEvent('cornerstone_recycle:server:toggleDuty', false)
    doNotifyClient(5000, 'Recycle Center', 'You are now off duty', 'success')
  else    
    onDuty = true
    if onDuty and not locationSet then    
      if not isCarryingPackage then      
        pickRandomLocation()
      end
     
    end
    doNotifyClient(5000, 'Recycle Center', 'You are now on duty', 'success')
    TriggerServerEvent('cornerstone_recycle:server:toggleDuty', true)
  end
end

local function SetupLaptop()
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = { recycleCenter.DutyLocation.x, recycleCenter.DutyLocation.y, recycleCenter.DutyLocation.z - 1.0 },
        name = 'recycle_center_laptop',
        heading = recycleCenter.DutyLocation.w,
        debug = Config.Debug,
        minZ = recycleCenter.DutyLocation.z,
        maxZ = recycleCenter.DutyLocation.z - 2.0,
        options = {
          {
            onSelect = function()
              ToggleDuty()
            end,
            icon = 'fas fa-recycle',
            label = 'Toggle Duty',
            distance = 1.5,
          },
        },
      }
      exports.ox_target:addBoxZone(parameters)
    end
  end
end

local function SetupInterior()
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = recycleCenter.Exit.xyz,
        name = 'recycle_center_exit',
        heading = recycleCenter.Exit.w,
        debug = Config.Debug,
        minZ = recycleCenter.Exit.z,
        maxZ = recycleCenter.Exit.z + 1.0,
        options = {
          {
            onSelect = function()
              ExitWarehouse()
            end,
            icon = 'fas fa-recycle',
            label = 'Exit Recycle Center',
            distance = 2.0,
          },
        },
      }
      exports.ox_target:addBoxZone(parameters)
    end
  end
end

local function SetupPed()
  LoadModel(ped.Model)  
  
  managerPed = CreatePed(0, ped.Model, ped.location.x, ped.location.y, ped.location.z - 1, ped.location.w, false, false)

  SetEntityAsMissionEntity(managerPed, true, true)
  SetBlockingOfNonTemporaryEvents(managerPed, true)
  FreezeEntityPosition(managerPed, true)
  SetEntityInvincible(managerPed, true)
  SetEntityHeading(managerPed, ped.location.w)
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = { ped.location.x, ped.location.y, ped.location.z - 1.0 },
        name = 'recycle_center_managerPed',
        heading = ped.location.w,
        debug = Config.Debug,
        minZ = ped.location.z,
        maxZ = ped.location.z - 2.0,
        options = {
          {
            onSelect = function()
              lib.showContext('recycle_manger_menu')
            end,
            icon = 'fas fa-comment-dollar',
            label = 'Buy/Sell Items',
            distance = 1.0,
          },
        },
      }
      exports.ox_target:addBoxZone(parameters)
    end
  end
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

-- Create Function to setup the recycle center using ox target and CreateBoxZone
local function SetupRecycleCenter()
  local parameters = {
    coords = recycleCenter.Enter.xyz,
    name = 'recycle_center_enter',
    heading = recycleCenter.Enter.w,
    debug = Config.Debug,
    minZ = recycleCenter.Enter.z,
    maxZ = recycleCenter.Enter.z + 1.0,
    options = {
      {
        onSelect = function()
          EnterWarehouse()
        end,
        icon = 'fas fa-recycle',
        label = 'Enter Recycle Center',
        distance = 2.0,
      },
    },
  }
  exports.ox_target:addBoxZone(parameters)
end

Citizen.CreateThread(function()     
  CreateBlip()
  SetupRecycleCenter()
  SetupContextMenu() 
end)
