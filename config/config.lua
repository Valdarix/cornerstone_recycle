Config = {}

Config.Debug = true

-------------------------------------------------------
----------------- Target Config ----------------        
-------------------------------------------------------
Config.UseTarget = true           -- setting to false will use interact instead of target
Config.Target = 'ox'              -- ox , qb

-------------------------------------------------------
----------------- Framework Config ---------------------   
-------------------------------------------------------
Config.Framework = 'auto'          -- auto, qbx , qb, esx, nd
Config.Inventory = 'ox'            -- ox , qb, esx, ps

-------------------------------------------------------
----------------- Notification Config ------------------
-------------------------------------------------------
Config.Notification = 'ox'         -- ox , qb, esx, k5, okok, xs
Config.XSLocation = 0              -- 0 Middle, 1 Bottom, 2 Left, 3 Right. THIS ONLY MATTERS IF Config.Notification = 'xs'

-------------------------------------------------------
----------------- Mini Game Config ------------------
-------------------------------------------------------
Config.Progress = 'ox-circle'      -- ox-normal , ox-circle , qb, esx
Config.OxCirclePosition = 'bottom' -- only matters if Config.Progress = 'ox-circle'


