
class @ProjectsList extends React.Component
	render: ->
		{projects} = @props
		E ".projects.sidebar",
			E "ul.projects-list",
				for project in projects
					E ProjectListItem, {key: project.id, project}
	
	componentDidMount: ->
		go = (delta)=>
			for project, i in ProjectNexus.projects
				if project.id is ProjectNexus.selected_project_id
					spi = i
			
			project = ProjectNexus.projects[spi + delta]
			ProjectNexus.select project.id if project?
		
		document.body.addEventListener "keydown", @keydown_listener = (e)->
			switch e.keyCode
				when 38 then go -1 # up
				when 40 then go +1 # down
				else return
			e.preventDefault()
	
	componentWillUnmount: ->
		document.body.removeEventListener "keydown", @keydown_listener
