
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
		has_menu = menu?.length
		if icon or menu
			icon ?= "octicon-primitive-dot"
			E ".launcher",
				class:
					"has-menu": has_menu
					"menu-open": @state.menu_open
				E "button.button.icobutton",
					class: "no-primary-action": not action
					onClick: =>
						clearTimeout @state.holding_tid
						if action
							unless @state.mouse_left
								@setState pressed_and_held: no, menu_open: no
								action()
					onContextMenu: (e)=>
						e.preventDefault()
						@setState menu_open: yes if has_menu
					onMouseDown: (e)=>
						@setState mouse_left: no
						e.preventDefault()
						clearTimeout @state.holding_tid
						if has_menu and e.button is 0
							@setState
								pressed: yes
								holding_tid: setTimeout =>
									@setState pressed_and_held: yes, menu_open: yes
								, 500
					onMouseLeave: =>
						@setState mouse_left: yes
						if has_menu and @state.pressed
							clearTimeout @state.holding_tid
							@setState pressed_and_held: yes, menu_open: yes
					
					title: title
					E "i", class: [icon, ("mega-octicon" if icon?.match /octicon-/)]
				if has_menu
					E "ul.launcher-context-menu.context-menu.menu.window-frame.csd",
						style: display: "block"
						class: "open" if @state.menu_open
						for item, i in menu then do (item, i)=>
							hovered = @state.hovered_menu_item_i is i
							E "li.menuitem",
								key: i
								class:
									hover: hovered
									active: hovered and @state.pressed_and_held
									selected: hovered and @state.pressed_and_held
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
			scroller = element.closest ".projects"
			
			@close_menu = (e)=>
				# NOTE: e.target can be the Window for blur events
				if e.target instanceof Node and menu.contains e.target
					e.preventDefault()
				else
					@setState menu_open: no
			window.addEventListener "mousedown", @close_menu
			window.addEventListener "blur", @close_menu
			window.addEventListener "mouseup", @mouseup_listener = (e)=>
				@setState pressed: no
				if @state.pressed_and_held
					setTimeout => @setState pressed_and_held: no
				else
					@close_menu(e)
			window.addEventListener "keydown", @keydown_listener = (e)=>
				@setState menu_open: no if e.keyCode is 27 # Escape
			
			@update_menu_position = =>
				return unless menu.classList.contains "open"
				menu.style.display = "block" # so menu_rect.height isn't 0
				launcher_rect = element.getBoundingClientRect()
				menu_rect = menu.getBoundingClientRect()
				scroller_rect = scroller.getBoundingClientRect()
				menu.style.display = ""
				# if it would go off the screen on the bottom
				if launcher_rect.bottom + menu_rect.height > scroller_rect.bottom
					# attach to the top of the launcher
					menu.style.top = "#{launcher_rect.top - menu_rect.height}px"
				else
					# attach to the bottom of the launcher
					menu.style.top = "#{launcher_rect.bottom}px"
				menu.style.left = "#{launcher_rect.left}px"
			
			scroller.addEventListener "scroll", @update_menu_position
			window.addEventListener "resize", @update_menu_position
			window.addEventListener "keydown", @update_menu_position
			window.addEventListener "click", @update_menu_position
			window.addEventListener "mousedown", @update_menu_position
			window.addEventListener "mouseup", @update_menu_position
	
	componentWillUnmount: ->
		element = React.findDOMNode @
		menu = element.querySelector ".launcher-context-menu"
		if menu
			scroller = element.closest ".projects"
		
		window.removeEventListener "mousedown", @close_menu
		window.removeEventListener "blur", @close_menu
		window.removeEventListener "mouseup", @mouseup_listener
		window.removeEventListener "keydown", @keydown_listener
		
		scroller?.removeEventListener "scroll", @update_menu_position
		window.removeEventListener "resize", @update_menu_position
		window.removeEventListener "keydown", @update_menu_position
		window.removeEventListener "click", @update_menu_position
		window.removeEventListener "mousedown", @update_menu_position
		window.removeEventListener "mouseup", @update_menu_position
	
	componentDidUpdate: ->
		if @state.active
			element = React.findDOMNode @
			menu = element.querySelector ".launcher-context-menu"
			if @state.pressed_and_held
				menu.children[@state.hovered_menu_item_i].focus()
		@update_menu_position?()
