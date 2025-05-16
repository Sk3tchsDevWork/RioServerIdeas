fx_version 'cerulean'
game 'gta5'

description 'Cartel Crypto Laundering Terminal System'

lua54 'yes'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}
