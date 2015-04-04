
class @ProjectsList extends React.Component
	constructor: ->
		# @state =
		# 	selected_project_id: null
		# 	# selected_project: null
		# 	# selected_project_index: -1
		
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
			# console.log e.keyCode
			switch e.keyCode
				when 38 then go -1 # up
				when 40 then go +1 # down
				else return
			e.preventDefault()
	
	select: (project)->
		if project
			#@setState selected_project_id: project.id
			# render()
			window.render ProjectNexus.selected_project_id = project.id
			setTimeout ->
				# document.querySelector(".active.project").scrollIntoView()
				document.querySelector(".active.project").scrollIntoViewIfNeeded()
	
	render: ->
		{projects, projects_read_error} = @props
		if projects_read_error
			E ".projects-read-error",
				E "p.error", "Failed to read projects from projects directory."
				E "p.subtle-error", projects_read_error.message
		else
			E "ul.projects",
				for project in projects
					E ProjectListItem, {project}
