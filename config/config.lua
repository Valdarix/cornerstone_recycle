Config = {}

Config.Debug = true

Config.Framework = 'auto'          -- auto, qbx , qb, esx,
Config.Inventory = 'qb'            -- ox , qb, esx, ps, qs

Config.UseTarget = true           -- setting to false will use interact instead of target
Config.Target = 'qb'              -- ox , qb

Config.Notification = 'qb'         -- ox , qb, esx, k5, okok, xs
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
        { name = 'prop_recyclebin_04_b', location = vec4(1006.60, -3097.65, -40.00, 1.38) },
        { name = 'prop_recyclebin_04_b', location = vec4(1005.50, -3097.73, -40.00, 359.93) },
        { name = 'prop_recyclebin_04_b', location = vec4(1004.21, -3097.77, -40.00, 358.86) },
        { name = 'prop_recyclebin_04_b', location = vec4(1003.09, -3097.75, -40.00, 0.68) },
        { name = 'prop_boxpile_06b', location = vec4(1018.30, -3102.78, -40.00, 179.63) },
        { name = 'prop_boxpile_06b', location = vec4(1010.87, -3103.07, -40.00, 177.57) },
        { name = 'prop_boxpile_01a', location = vec4(1008.51, -3103.10, -40.00, 221.40) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.68, -3092.37, -40.00, 358.23) },
        { name = 'prop_recyclebin_04_b', location = vec4(1017.59, -3092.32, -40.00, 359.80) },
        { name = 'prop_recyclebin_04_b', location = vec4(1015.15, -3092.31, -40.00, 359.42) },
        { name = 'prop_boxpile_04a', location = vec4(1006.01, -3103.00, -39.24, 181.52) },
        { name = 'prop_boxpile_04a', location = vec4(1015.60, -3108.42, -39.24, 175.08) },
        { name = 'prop_boxpile_04a', location = vec4(1003.62, -3103.19, -39.24, 167.08)},
        { name = 'prop_boxpile_04a', location = vec4(1003.56, -3108.39, -39.24, 181.46) },
        { name = 'prop_recyclebin_04_b', location = vec4(1013.84, -3092.37, -40.00, 359.11) },
        { name = 'prop_recyclebin_04_b', location = vec4(1010.32, -3092.32, -40.00, 359.11) },
        { name = 'prop_recyclebin_04_b', location = vec4(1009.01, -3092.30, -40.00, 359.11) },
        { name = 'prop_recyclebin_04_b', location = vec4(1007.89, -3092.28, -40.00, 359.11) },
        { name = 'prop_recyclebin_04_b', location = vec4(1005.51, -3092.24, -40.00, 359.11) },
        { name = 'prop_boxpile_06b', location =  vec4(1010.84, -3108.16, -40.00, 185.57) },
        { name = 'prop_recyclebin_04_b', location = vec4(1004.24, -3092.24, -40.00, 359.24) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.64, -3097.72, -40.00, 0.87) },
        { name = 'prop_recyclebin_04_b', location = vec4(1015.17, -3103.39, -40.00, 359.67) },
        { name = 'prop_boxpile_04a', location = vec4(1015.69, -3096.94, -39.24, 180.70) },
        { name = 'prop_recyclebin_04_b', location = vec4(1018.71, -3096.32, -40.00, 180.60) },
        { name = 'prop_recyclebin_04_b', location = vec4(1016.19, -3102.08, -40.00, 178.83) },
        { name = 'prop_recyclebin_04_b', location = vec4(1012.85, -3096.30, -40.00, 179.65) },
        { name = 'prop_recyclebin_04_b', location = vec4(1011.44, -3096.30, -40.00, 179.40) },
        { name = 'prop_recyclebin_04_b', location = vec4(1010.38, -3096.41, -40.00, 179.21) },
        { name = 'prop_recyclebin_04_b', location = vec4(1007.91, -3096.37, -40.00, 181.10) },
        { name = 'prop_recyclebin_04_b', location = vec4(1012.75, -3097.58, -40.00, 0.05) },
        { name = 'prop_recyclebin_04_b', location = vec4(1006.58, -3096.38, -40.00, 180.98) },
        { name = 'prop_recyclebin_04_b', location = vec4(1003.10, -3096.27, -40.00, 179.09) },
        { name = 'prop_recyclebin_04_b', location = vec4(1011.41, -3097.71, -40.00, 358.54) },
        { name = 'prop_recyclebin_04_b', location = vec4(1010.32, -3097.71, -40.00, 358.73) },
    },
    Rewards = {
        MinRewardItems = 1,
        MaxRewardItems = 5,
        Items = {
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
                Item = 'aluminium',
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
            {
                Item = 'metalscrap',
                Amount = math.random(1, 5),
                SellPrice = 5,
                BuyPrice = 1,
            },
            {
                Item = 'iron',
                Amount = math.random(1, 5),
                SellPrice = 5,
                BuyPrice = 1,
            },
            {
                Item = 'copper',
                Amount = math.random(1, 5),
                SellPrice = 5,
                BuyPrice = 1,
            },
        }
    },
}
