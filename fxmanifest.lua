fx_version 'cerulean'
game 'gta5'

author 'Cornerstone Scripts'
description 'cs_template'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua',
    -- "@ND_Core/init.lua"
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'
