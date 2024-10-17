fx_version 'adamant'
game 'gta5'
description 'talk to npc by The Ripper'
version      '1.0.0'

ui_page "html/index.html"

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/main.lua',
	'client/peds.lua'
}

files {
    'html/index.html',
	'html/index.css',
	'html/index.js',
	'html/images/*'
}