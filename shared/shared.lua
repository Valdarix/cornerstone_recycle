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
    DebugPrint('Cornerstone Recycling using Community Bridge auto-detection')
    if Config.UseTarget then
        DebugPrint('++ Using target interactions')
    else
        DebugPrint('++ Using interact interactions')
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(10000)
    DetectCore()
end)
