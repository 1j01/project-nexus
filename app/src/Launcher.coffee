
class @Launcher extends React.Component
	constructor: ->
		@state =
			menu_open: no
			pressed: no
			pressed_and_held: no
			mouse_left: no
			holding_tid: null
			active_menu_item_i: null
	
	render: ->
		{action, title, icon, menu} = @props
		
		if icon or menu
			icon ?= "octicon-primitive-dot"
			E ".launcher",
				# class: ["has-menu", "menu-open" if @state.menu_open] if menu # haha ReactScript
				class:
					"has-menu": menu?
					"menu-open": @state.menu_open
				E "button",
					class: "no-primary-action": not action
					onClick: =>
						clearTimeout @state.holding_tid
						if action
							unless @state.mouse_left
								@setState pressed_and_held: no, menu_open: no
								action()
					onContextMenu: (e)=>
						e.preventDefault()
						@setState menu_open: yes if menu
					onMouseDown: (e)=>
						@setState mouse_left: no
						e.preventDefault()
						clearTimeout @state.holding_tid
						if menu and e.button is 0
							@setState
								pressed: yes
								holding_tid: setTimeout =>
									@setState pressed_and_held: yes, menu_open: yes
								, 500
					onMouseLeave: =>
						@setState mouse_left: yes
						if menu and @state.pressed
							clearTimeout @state.holding_tid
							@setState pressed_and_held: yes, menu_open: yes
							# @TODO: open the menu when you move the mouse below the launcher, not just outside of it
					
					title: title
					E "i", class: [icon, ("mega-octicon" if icon?.match /octicon-/)]
				if menu
					E "ul.launcher-context-menu",
						class: "open" if @state.menu_open
						for item, i in menu then do (item, i)=>
							hovered = @state.hovered_menu_item_i is i
							E "li",
								class:
									hover: hovered
									active: hovered and @state.pressed_and_held
								onMouseEnter: =>
									@setState hovered_menu_item_i: i
								onMouseLeave: =>
									@setState hovered_menu_item_i: null
								onMouseDown: =>
									@setState pressed_and_held: yes
								onMouseUp: (e)=>
									if @state.pressed_and_held
										e.preventDefault() # prevent click handler from duplicating item.action() call
										@setState menu_open: no
										item.action()
								onClick: =>
									@setState menu_open: no
									item.action()
								item.text ? item.name
					# @TODO: keyboard navigation
		else
			E ".launcher"
	
	componentDidMount: ->
		element = React.findDOMNode @
		menu = element.querySelector ".launcher-context-menu"
		if menu
			close_menu = (e)=>
				if menu.contains e.target
					e.preventDefault()
				else
					@setState menu_open: no
			scroller = element
			scroller = scroller.parentElement until scroller.classList.contains "projects"
			do update_menu_position = =>
				menu.style.top = "#{element.getBoundingClientRect().bottom}px"
			setTimeout update_menu_position, 50 # @HACK because it wouldn't position correctly initially
			window.addEventListener "mousedown", close_menu
			window.addEventListener "blur", close_menu
			window.addEventListener "mouseup", (e)=>
				@setState pressed: no
				if @state.pressed_and_held
					setTimeout => @setState pressed_and_held: no
				else
					close_menu(e)
			window.addEventListener "keydown", (e)=> @setState menu_open: no if e.keyCode is 27 # Escape
			scroller.addEventListener "scroll", update_menu_position
			window.addEventListener "resize", update_menu_position
