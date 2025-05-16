fx_version 'cerulean'
game 'gta5'

description 'DEA Raid Breach System with Heat-Based Logic'

lua54 'yes'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}
