
class @Launcher extends React.Component
	constructor: ->
		@state = menu_open: no
	
	render: ->
		{action, title, icon, menu} = @props

		if icon
			E ".launcher",
				class: "menu-open" if @state.menu_open
				E "button",
					onClick: action
					onContextMenu: => @setState menu_open: yes if menu
					# @TODO: open the menu by either
					# * pressing and holding on the button
					# * dragging down from the button
					title: title
					E "i", class: [icon, ("mega-octicon" if icon?.match /octicon-/)]
				if menu
					E "ul.menu",
						class: "open" if @state.menu_open
						for item in menu then do (item)=>
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
				if menu.contains e.target
					e.preventDefault()
				else
					@setState menu_open: no
			scroller = element
			scroller = scroller.parentElement until scroller.classList.contains "projects"
			do update_menu_position = =>
				console.log element.clientHeight
				# menu.style.top = "#{element.offsetTop + scroller.offsetTop - scroller.scrollTop}px"
				menu.style.top = "#{element.getBoundingClientRect().bottom}px"
			window.addEventListener "mousedown", close_menu
			window.addEventListener "mouseup", close_menu
			window.addEventListener "keydown", (e)=> @setState menu_open: no if e.keyCode is 27 # Escape
			scroller.addEventListener "scroll", update_menu_position
			window.addEventListener "resize", update_menu_position
