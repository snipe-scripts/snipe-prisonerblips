-----------------For support, scripts, and more----------------
--------------- https://discord.gg/VGYkkAYVv2  -------------
---------------------------------------------------------------

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description "Blip System for DOC"
author "Snipe"
version '1.0.0'


shared_scripts{
    'shared/*.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/**/*.lua',
}

server_scripts {
	'server/**/*.lua'
}
