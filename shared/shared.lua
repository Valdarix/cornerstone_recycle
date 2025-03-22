Config = Config or {}

function LoadModel(model)
    RequestModel(model)
    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() - startTime > 5000 then
            DebugPrint("ERROR: Model load timeout:" .. " " .. model)
            break
        end
    end
end

function DebugPrint(...)
    if Config.Debug then print('^3[DEBUG]^7', ...) end
end

function DetectCore()
    if Config.Framework == 'auto' then
        if GetResourceState('qbx_core') == 'started' then
            Config.Framework = 'qbx'
        elseif GetResourceState('qb-core') == 'started' then
            Config.Framework = 'qb'
        elseif GetResourceState('es_extended') == 'started' then
            Config.Framework = 'qb'       
        else
            Config.Framework = 'none'
        end
    end

    DebugPrint('Cornerstone Recyling Started with for the : ' .. Config.Framework .. ' framework')
    DebugPrint('++ Notifications: ' .. Config.Notification)
    DebugPrint('++ Inventory: ' .. Config.Inventory)
    if Config.UseTarget then
        DebugPrint('++ Target: ' .. Config.Target)
    else
        DebugPrint('++ Target is Disabled')
    end
   
    DebugPrint('++ Progress: ' .. Config.Progress)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(10000)
    DetectCore()
end)