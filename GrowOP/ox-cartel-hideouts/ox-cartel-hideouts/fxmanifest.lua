fx_version 'cerulean'
game 'gta5'

description 'Cartel Hideouts - ox_target, ox_doorlock, Secure Stashes'

lua54 'yes'

shared_script '@ox_lib/init.lua'
client_scripts {
    'client/*.lua'
}
server_scripts {
    'server/*.lua'
}
