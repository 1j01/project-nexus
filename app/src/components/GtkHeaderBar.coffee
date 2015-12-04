
gui = require "nw.gui"
win = gui.Window.get()

class @GtkHeaderBar extends React.Component
	constructor: ->
		@state = maximized: no
	
	render: ->
		E ".titlebar",
			E TitleButton,
				key: "close"
				action: -> window.close()
				icon: "close"
			
			@props.children ? E ".title", document.title
			
			E TitleButton,
				key: "maximize"
				if @state.maximized
					action: -> win.restore()
					icon: "restore"
				else
					action: -> win.maximize()
					icon: "fullscreen"
	
	componentDidMount: ->
		win.on "maximize", @onmaximize = => @setState maximized: yes
		win.on "unmaximize", @onunmaximize = => @setState maximized: no
	
	componentWillUnmount: ->
		win.removeListener "maximize", @onmaximize
		win.removeListener "unmaximize", @onunmaximize

