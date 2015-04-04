
class @ProjectNexus extends React.Component
	@projects = []
	@projects_read_error = null
	@selected_project_id = null
	
	render: ->
		for project in ProjectNexus.projects
			if project.id is ProjectNexus.selected_project_id
				active_project = project
		
		E "div.app",
			E "header",
				E "h1", "Project Nexus"
				E "button",
					onClick: Settings.show
					E "i.mega-octicon.octicon-gear"
			E "main",
				E ProjectsList,
					projects: ProjectNexus.projects
					projects_read_error: ProjectNexus.projects_read_error
				E ProjectDetails,
					project: active_project
			E Settings
