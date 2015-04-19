
class @ProjectNexus extends React.Component
	@projects = []
	@projects_read_error = null
	@selected_project_id = null
	
	render: ->
		for project in ProjectNexus.projects
			if project.id is ProjectNexus.selected_project_id
				active_project = project
		
		E GtkWindow, {},
			E GtkHeaderBar, {},
				E "h1.title", "Project Nexus"
				E TitleButton,
					action: Settings.toggle
					E "i.mega-octicon.octicon-gear"
			E ".window-content",
				E "main",
					E ProjectsList,
						projects: ProjectNexus.projects
						projects_read_error: ProjectNexus.projects_read_error
					E ProjectDetails,
						project: active_project
				E Settings
