
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
		win.on "focus", @onfocus = => @setState active: yes
		win.on "blur", @onblur = => @setState active: no
		win.on "maximize", @onmaximize = => @setState maximized: yes
		win.on "unmaximize", @onunmaximize = => @setState maximized: no
	
	componentWillUnmount: ->
		win.removeListener "focus", @onfocus
		win.removeListener "blur", @onblur
		win.removeListener "maximize", @onmaximize
		win.removeListener "unmaximize", @onunmaximize
	
