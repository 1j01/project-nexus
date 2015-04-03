
fs = require "fs"
{join} = require "path"

gui = window.require "nw.gui"
E = window.ReactScript

# @TODO: HTTP server
# @TODO: Live reload

module.exports = (project)->
	index_path = join project.path, "index.html"
	if fs.existsSync index_path
		
		open = ->
			gui.Shell.openExternal "file://#{index_path}"
		
		E "button",
			onClick: open
			title: "open index.html"
			E "i.mega-octicon.octicon-globe"
