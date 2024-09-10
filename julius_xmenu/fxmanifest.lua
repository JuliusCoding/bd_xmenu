fx_version 'adamant'

game 'gta5'

author 'Julius'
version '1.0.0'
description 'Julius`s X-Menu'
dependency 'julius_fesseln'

ui_page "html/index.html"

files {
	"html/index.html",
	"html/imgs/*.png",
	"html/imgs/function-icons/*.png",
	

}

client_scripts {
	"client.lua",
}

server_scripts {
	"server.lua",
}