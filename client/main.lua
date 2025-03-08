if Config.Framework == 'qb' or Config.Framework == 'qbx' then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end
if Config.Framework == 'qbx' then QBX = exports.qbx_core end
if Config.Framework == 'nd' then ND = exports["ND_Core"] end

local recycleCenter = Config.RecycleCenter
local ped = recycleCenter.Ped
local pickLocations = recycleCenter.Locations

local blip = nil
local onDuty = false

local managerPed = nil

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

RegisterNetEvent('nameOFscript:client:nameOFwhathappens', function()
  -- Templete netevent
end)

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end

  -- code here
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
  if not onDuty then
    local playerPed = PlayerPedId()
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetEntityCoords(playerPed, recycleCenter.Enter.x, recycleCenter.Enter.y, recycleCenter.Enter.z, false, false, false,
      false)
    SetEntityHeading(playerPed, recycleCenter.Enter.w)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)

    -- Cleanup
    if Config.UseTarget then
      if Config.Target == 'ox' then
        exports.ox_target:removeZone('recycle_center_exit')
        exports.ox_target:removeZone('recycle_center_laptop')
        exports.ox_target:removeZone('recycle_center_managerPed')
      end
    end

    if managerPed ~= nil and DoesEntityExist(managerPed) then
      DeleteEntity(managerPed)
    end
  else
    exports('doNotify', doNotify)(5000, 'Recycle Center', 'You must go off duty first', 'error')
  end
end

local function ToggleDuty()
  if onDuty then
    onDuty = false
    doNotifyClient(5000, 'Recycle Center', 'You are now off duty', 'success')
  else
    onDuty = true
    doNotifyClient(5000, 'Recycle Center', 'You are now on duty', 'success')
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
  managerPed = CreatePed(0, ped.Model, ped.Location.x, ped.Location.y, ped.Location.z - 1, ped.Location.w, false, false)

  SetEntityAsMissionEntity(managerPed, true, true)
  SetBlockingOfNonTemporaryEvents(managerPed, true)
  FreezeEntityPosition(managerPed, true)
  SetEntityInvincible(managerPed, true)
  SetEntityHeading(managerPed, ped.Location.w)
  if Config.UseTarget then
    if Config.Target == 'ox' then
      local parameters = {
        coords = { ped.Location.x, ped.Location.y, ped.Location.z - 1.0 },
        name = 'recycle_center_managerPed',
        heading = ped.Location.w,
        debug = Config.Debug,
        minZ = ped.Location.z,
        maxZ = ped.Location.z - 2.0,
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


Citizen.CreateThread(function() -- Start Thread (Non Loop)
  CreateBlip()
  SetupRecycleCenter()
  SetupContextMenu()
end)


-- Citizen.CreateThread(function() -- Start Thread (Loop) (Uncomment if going to use it)
--     while true do
--         Wait(10)
--     end
-- end)
