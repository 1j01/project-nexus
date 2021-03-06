
class @ProjectNexus extends React.Component
	
	@select: (project_id)->
		window.render ProjectNexus.selected_project_id = project_id
		localStorage.selected_project_id = project_id
		setTimeout ->
			document.querySelector(".selected.project")?.scrollIntoViewIfNeeded()
	
	render: ->
		{projects, projects_read_error, selected_project_id, runaway_processes} = ProjectNexus
		
		if projects
			for project in projects
				if project.id is selected_project_id
					selected_project = project
		
		Window = if Settings.get "elementary" then GtkWindow else ".app.window-frame.active"
		Header = if Settings.get "elementary" then GtkHeaderBar else "header"
		
		E Window,
			E Header,
				E "h1.title", "Project Nexus"
				E "button.button.titlebutton",
					style:
						margin: 0
						padding: 0
						alignSelf: "center"
					onClick: Settings.toggle
					E "img",
						src: "img/gear.svg"
						style:
							verticalAlign: "middle"
							pointerEvents: "none"
			if projects_read_error or projects?.length is 0
				dir_not_found = projects_read_error?.code is "ENOENT"
				E "GtkInfoBar",
					class: if dir_not_found or (not projects_read_error) then "warning" else "error"
					E "GtkLabel",
						if projects_read_error
							if dir_not_found
								"Couldn't find your projects directory"
							else
								"Failed to read projects from your projects directory"
						else
							"There are no project folders in your projects directory (#{Settings.get "projects_dir"})"
					E "button.button",
						onClick: ->
							chooser = document.createElement "input"
							chooser.setAttribute "type", "file"
							chooser.setAttribute "nwdirectory", "nwdirectory"
							chooser.addEventListener "change", (e)=>
								Settings.set "projects_dir", e.target.value
								window.render()
							chooser.click()
						E "GtkLabel", "Browse"
			
			E ".window-content", key: "window-content",
				E "main",
					if projects?.length > 0
						[
							E ProjectsList, key: "projects", projects: projects
							E ProjectDetails, key: "project", project: selected_project
						]
					else
						E WelcomeScreen, key: "welcome"
					
					if runaway_processes?.length
						E RunawayProcesses, {key: "runaways", runaway_processes}
				
				E Settings
