
class @ProjectsList extends React.Component
	constructor: ->
		go = (delta)=>
			for project, i in ProjectNexus.projects
				if project.id is ProjectNexus.selected_project_id
					spi = i
			
			spi += delta
			
			if Settings.get "list_wrap"
				@select ProjectNexus.projects[spi %% ProjectNexus.projects.length]
			else
				@select ProjectNexus.projects[spi]
		
		window.addEventListener "keydown", (e)->
			switch e.keyCode
				when 38 then go -1 # up
				when 40 then go +1 # down
				else return
			e.preventDefault()
	
	select: (project)->
		if project
			window.render ProjectNexus.selected_project_id = project.id
			document.querySelector(".selected.project").scrollIntoViewIfNeeded()
	
	render: ->
		{projects, projects_read_error} = @props
		if projects_read_error?
			E ".no-projects",
				E "p.error", "Failed to read projects from projects directory."
				E "p.subtle-error", projects_read_error.message
		else if not projects?
			E ".no-projects",
				E "p", ""
				E "p.subtle-error",
					if (Settings.get "projects_dir")?
						"No projects directory"
					else
						"No projects directory (yet)"
		else
			E "ul.projects",
				for project in projects
					E ProjectListItem, {project}
