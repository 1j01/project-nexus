
class @ProjectListItem extends React.Component
	constructor: ->
		@state = active: no
	render: ->
		{project} = @props
		{hover, active} = @state
		{id, path, dirname, name, pkg} = project
		selected = ProjectNexus.selected_project_id is id
		
		is_relevant = (event)->
			el = event.target
			while el
				return no if el.classList.contains "launcher"
				return no if el.nodeName is "BUTTON"
				el = el.parentElement
			return yes
		
		E "li.project.view",
			tabIndex: -1
			title: path
			class: {hover, active, selected}
			onClick: => ProjectNexus.select id
			onMouseDown: (e)=> @setState active: yes if is_relevant e
			onMouseEnter: (e)=> @setState hover: yes
			onMouseLeave: (e)=> @setState hover: no
			
			E ".launcher",
				key: "folder"
				E "button.button.icobutton",
					onClick: => (require "nw.gui").Shell.openItem path
					E "i.mega-octicon.octicon-file-directory"
			
			E "span.project-name", key: "name", name
			
			for launcher_module, i in launchers
				props = launcher_module project
				props ?= {}
				props.key = i
				E Launcher, props
					
	
	componentDidMount: ->
		window.addEventListener "mouseup", @mouseup_listener = =>
			@setState active: no
	
	componentWillUnmount: ->
		window.removeEventListener "mouseup", @mouseup_listener
