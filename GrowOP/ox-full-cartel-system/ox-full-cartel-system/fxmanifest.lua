fx_version 'cerulean'
game 'gta5'

description 'OX-Based Full Cartel Framework with Drugs, Heat, Transport, DEA Risk'

lua54 'yes'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}
