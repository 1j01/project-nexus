
gui = require "nw.gui"
win = gui.Window.get()

class @GtkHeaderBar extends React.Component
	constructor: ->
		@state = maximized: no
	
	render: ->
		E ".titlebar",
			E TitleButton,
				action: -> window.close()
				icon: "close"
			
			@props.children ? E ".title", document.title
			
			E TitleButton,
				if @state.maximized
					action: -> win.restore()
					icon: "restore"
				else
					action: -> win.maximize()
					icon: "fullscreen"
	
	componentDidMount: ->
		win.on "maximize", => @setState maximized: yes
		win.on "unmaximize", => @setState maximized: no

