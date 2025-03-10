if Config.Framework == 'qb' or Config.Framework == 'qbx' then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end
if Config.Framework == 'qbx' then QBX = exports.qbx_core end

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
  if Config.UseTarget then
    if Config.Target == 'ox' then
      exports.ox_target:removeZone('recycle_center_exit')
      exports.ox_target:removeZone('recycle_center_laptop')
      exports.ox_target:removeLocalEntity(managerPed)
      exports.ox_target:removeLocalEntity(dropOffObj)
    end
  end

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
  if Config.UseTarget then
    if Config.Target == 'ox' then
      exports.ox_target:addLocalEntity(dropOffObj, {
        {
          distance = 1.5,
          name = 'recycle_center_dropoff',
          icon = 'recycle',
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
  end
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
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = { randomLocation.location.x, randomLocation.location.y, randomLocation.location.z + 0.5 },
        size = { x = 2.0, y = 2.0, z = 2.0 },
        name = pickupId,
        heading = randomLocation.location.w,
        debug = Config.Debug,
        minZ = randomLocation.location.z,
        maxZ = randomLocation.location.z + 2.0,
        options = {
          {
            onSelect = function()
              if not isCarryingPackage then
                isCarryingPackage = true
                doNotifyClient(5000, 'Recycle Center', 'You have picked up a load!', 'success')
                GrabPackage(randomLocation.name, randomLocation.location)

                exports.ox_target:removeZone(pickupId)
              else
                doNotifyClient(5000, 'Recycle Center', 'You are already carrying a load!', 'error')
              end
            end,
            icon = 'fas fa-hand',
            label = 'Pickup Recycling',
            distance = 1.0,
          },
        },
      }
      exports.ox_target:addBoxZone(parameters)
      DebugPrint('Added pickup location')
    end
  end
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

local function SetupContextMenu()
  lib.registerContext({
    id = 'recycle_manger_menu',
    title = 'Recycling Shop',
    options = {
      {
        title = 'Sell Materials',
        description = 'Sell your gathered materials.',
        icon = 'fas fa-money-bill-wave',
        onSelect = function()
          print("Pressed the button!")
        end,
        metadata = {
          { label = 'Value 1', value = 'Some value' },
          { label = 'Value 2', value = 300 }
        },
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

  lib.showContext('recycle_manger_menu')
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
    locationSet = false
    isCarryingPackage = false
    currentPackage = 0
    exports.ox_target:removeZone(pickupId)

    TriggerServerEvent('cornerstone_recycle:server:toggleDuty', false)
    doNotifyClient(5000, 'Recycle Center', 'You are now off duty', 'success')
  else
    onDuty = true    
    doNotifyClient(5000, 'Recycle Center', 'You are now on duty', 'success')
    TriggerServerEvent('cornerstone_recycle:server:toggleDuty', true)
  end
end

local function SetupLaptop()
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = { recycleCenter.DutyLocation.x, recycleCenter.DutyLocation.y, recycleCenter.DutyLocation.z - 1.0 },
        size = { x = 1.0, y = 1.0, z = 1.0 },
        name = 'recycle_center_laptop',
        heading = recycleCenter.DutyLocation.w,
        debug = Config.Debug,
        minZ = recycleCenter.DutyLocation.z,
        maxZ = recycleCenter.DutyLocation.z - 2.0,
        distance = 1.0,
        options = {
          {
            onSelect = function()
              ToggleDuty()
            end,
            icon = 'fas fa-recycle',
            label = 'Toggle Duty',
            distance = 1.0,
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
      exports.ox_target:addLocalEntity(managerPed, {
        {
          distance = 1.5,
          name = 'recycle_center_managerPed',
          icon = 'fas fa-comment-dollar',
          label = 'Buy/Sell Items',
          onSelect = function()
            SetupContextMenu()
          end,
        }
      })
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
    size = { x = 5.0, y = 2.0, z = 5.0 },
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
  while true do
    Citizen.Wait(500)
    if onDuty then
      if not isCarryingPackage and not locationSet then
        pickRandomLocation()   
        DebugPrint(randomLocation.location.x .. ' ' .. randomLocation.location.y .. ' ' .. randomLocation.location.z)
        DrawMarker(1, randomLocation.location.x, randomLocation.location.y, randomLocation.location.z, 0, 0, 0, 0, 0, 0, 10, 10, 10, 0, 100, 100,  100, false, false, 2, true, nil, nil, false)          
      end
    end
  end
end)
