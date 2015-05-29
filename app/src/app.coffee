
fs = require "fs"

require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./app/launchers"
		require "./launchers/#{fname}"


do @render = ->
	React.render (React.createElement ProjectNexus), document.body
