fx_version 'adamant'

game 'gta5'

description 'Squizers Job Switch Script'

client_script 'client/main.lua'

version '1.0.0'

server_scripts {
    'server/main.lua',
    '@mysql-async/lib/MySQL.lua'
}