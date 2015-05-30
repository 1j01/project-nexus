
fs = require "fs"
{join} = require "path"

gui = window.require "nw.gui"
E = window.ReactScript

# @TODO: HTTP server
# @TODO: Live reload (with an HTTP server)

module.exports = (project)->
	index_path = join project.path, "index.html"
	if fs.existsSync index_path
		# @FIXME: this unpredictably fails; use an HTTP server
		action: -> gui.Shell.openItem index_path
		title: "open index.html"
		icon: "octicon-globe"

# @PLZ: add HTTP server @KTHXBAI
