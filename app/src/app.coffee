
fs = require "fs"

require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./app/src/launchers"
		require "./src/launchers/#{fname}"


do @render = ->
	React.render (React.createElement ProjectNexus), document.body
	document.body.classList.remove "not-loaded"

setTimeout ->
	ProjectNexus.select localStorage.selected_project_id


nw.Window.get().on "new-win-policy", (frame, url, policy)->
	# do not open the window
	policy.ignore()
	# open url in external browser
	nw.Shell.openExternal(url)
