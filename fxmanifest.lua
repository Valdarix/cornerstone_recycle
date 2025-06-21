fx_version 'cerulean'
game 'gta5'

author 'Cornerstone Scripts'
description 'Cornerstreone Scripts Recycling Script'
version '1.0.0'

shared_scripts {  
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',   
    'server/*.lua'
}

client_scripts {
    'client/*.lua',  
}

dependencies {
    'ox_lib',
    'community_bridge',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

lua54 'yes'
use_fxv2_oal 'yes'
dependency 'community_bridge'
