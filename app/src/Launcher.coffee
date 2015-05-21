
class @Launcher extends React.Component
	constructor: ->
		@state = menu_open: no
	
	render: ->
		{action, title, icon, menu} = @props

		if icon
			E ".launcher",
				E "button",
					onClick: action
					onContextMenu: => @setState menu_open: yes
					# @TODO: open the menu by either
					# * pressing and holding on the button
					# * dragging down from the button
					title: title
					E "i", class: [icon, ("mega-octicon" if icon?.match /octicon-/)]
				if menu
					E "ul.menu",
						class: "hidden" unless @state.menu_open
						for item in menu
							E "li",
								onClick: =>
									@setState menu_open: no
									item.action()
								item.text ? item.name
					# @TODO: keyboard navigation
		else
			E ".launcher"
	
	componentDidMount: ->
		element = React.findDOMNode @
		menu = element.querySelector ".menu"
		if menu
			close_menu = (e)=>
				unless menu.contains e.target
					@setState menu_open: no
			window.addEventListener "mousedown", close_menu
			window.addEventListener "mouseup", close_menu
