Config = {}

Config.Debug = true

Config.Framework = 'auto'          -- auto, qbx , qb, esx, nd
Config.Inventory = 'ox'            -- ox , qb, esx, ps

Config.UseTarget = true           -- setting to false will use interact instead of target
Config.Target = 'ox'              -- ox , qb

Config.Notification = 'ox'         -- ox , qb, esx, k5, okok, xs
Config.XSNotifyLocation = 0              -- 0 Middle, 1 Bottom, 2 Left, 3 Right. THIS ONLY MATTERS IF Config.Notification = 'xs'

Config.Progress = 'ox-circle'      -- ox-normal , ox-circle , qb, esx
Config.OxCirclePosition = 'bottom' -- only matters if Config.Progress = 'ox-circle'

Config.RecycleCenter = {
    Enter = vec4(-572.05, -1631.29, 19.41, 181.47),
    Exit = vec4(1027.61, -3101.39, -39.0, 89.26),
    DropOff = {
        model = 'prop_recyclebin_05_a', 
        location = vec4(994.28, -3106.45, -40.00, 89.45)},       
    Ped = {
        Model = 's_m_m_gentransport',
        location = vec4(993.86, -3103.04, -39.0, 1.69),
    },
    DutyLocation = vec4(995.18, -3099.99, -38.18, 8.18),    
    PickupModels = {
        { name = 'prop_recyclebin_05_a', location = vec4(1018.16, -3101.83, -40.00, 179.74) },
        { name = 'prop_recyclebin_04_a', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_a', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_a', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_a', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.21, -3101.84, -40.00, 179.51) },
        'prop_recyclebin_04_b',
        'prop_recyclebin_04_a',
        'prop_recyclebin_04_a',
        'prop_recyclebin_04_b',
    },
    Rewards = {
        {
            Item = 'glass',
            Amount = math.random(1, 5),
            SellPrice = 5,
            BuyPrice = 1,
        },
        {
            Item = 'steel',
            Amount = math.random(1, 5),
            SellPrice = 5,
            BuyPrice = 1,
        },
        {
            Item = 'plastic',
            Amount = math.random(1, 5),
            SellPrice = 5,
            BuyPrice = 1,
        },
        {
            Item = 'aluminum',
            Amount = math.random(1, 5),
            SellPrice = 5,
            BuyPrice = 1,
        },
        {
            Item = 'rubber',
            Amount = math.random(1, 5),
            SellPrice = 5,
            BuyPrice = 1,
        },
    },
}
