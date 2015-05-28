
fs = require "fs"

gui = require "nw.gui"
win = window.win = gui.Window.get()


require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./app/launchers"
		require "./launchers/#{fname}"


do @render = ->
	React.render (React.createElement ProjectNexus), document.body


win.show() unless win.shown
win.shown = yes
