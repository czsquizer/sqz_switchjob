fx_version 'adamant'

game 'gta5'

description 'Squizers Job Switch Script'

client_scripts {    
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'client/main.lua'
}

version '1.0.3'

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'server/main.lua',
    '@mysql-async/lib/MySQL.lua'
}