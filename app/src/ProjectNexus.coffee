
class @ProjectNexus extends React.Component
	@projects = null
	@projects_read_error = null
	@selected_project_id = null
	
	render: ->
		if ProjectNexus.projects
			for project in ProjectNexus.projects
				if project.id is ProjectNexus.selected_project_id
					selected_project = project
		
		Window = if Settings.get "elementary" then GtkWindow else ".app.non-elementary"
		Header = if Settings.get "elementary" then GtkHeaderBar else "header"
		
		E Window, {},
			E Header, {},
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
						project: selected_project
				E Settings
