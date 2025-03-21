fx_version 'cerulean'
game 'gta5'

author 'Cornerstone Scripts'
description 'Cornerstreone Scripts Recycling Script with disconnect protection'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua',   
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'
