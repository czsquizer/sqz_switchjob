fx_version 'adamant'

game 'gta5'

description 'Squizers Job Switch Script'

client_script 'client/main.lua'

version '1.0.3'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}