
fs = require "fs"

require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./app/src/launchers"
		require "./src/launchers/#{fname}"


do @render = ->
	React.render (React.createElement ProjectNexus), document.body
