
class @ProjectListItem extends React.Component
	constructor: ->
		@state = active: no
	render: ->
		{project} = @props
		{hover, active} = @state
		{id, path, dirname, name, pkg} = project
		
		is_relevant = (event)->
			el = event.target
			while el
				return no if el.classList.contains "launcher"
				return no if el.nodeName is "BUTTON"
				el = el.parentElement
			return yes
		
		E "li.project.view",
			key: id
			tabIndex: -1
			title: path
			class: [
				"selected" if ProjectNexus.selected_project_id is id
				{hover, active}
			]
			onClick: => window.render ProjectNexus.selected_project_id = id
			onMouseDown: (e)=> @setState active: yes if is_relevant e
			onMouseEnter: (e)=> @setState hover: yes
			onMouseLeave: (e)=> @setState hover: no
			
			E ".launcher",
				E "button.button.icobutton",
					onClick: => (require "nw.gui").Shell.openItem path
					E "i.mega-octicon.octicon-file-directory"
			
			E "span.project-name", name
			
			for launcher_module in launchers
				E Launcher, launcher_module project
	
	componentDidMount: ->
		window.addEventListener "mouseup", =>
			@setState active: no
