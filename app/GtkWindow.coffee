
gui = require "nw.gui"
win = gui.Window.get()

class @GtkWindow extends React.Component
	constructor: ->
		@state = active: yes
	
	render: ->
		{active, maximized} = @state
		E ".window-frame",
			class: {active, maximized}
			@props.children
	
	componentDidMount: ->
		win.on "focus", => @setState active: yes
		win.on "blur", => @setState active: no
		win.on "maximize", => @setState maximized: yes
		win.on "unmaximize", => @setState maximized: no
	
