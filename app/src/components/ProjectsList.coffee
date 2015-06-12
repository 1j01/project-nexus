
class @ProjectsList extends React.Component
	constructor: ->
		go = (delta)=>
			for project, i in ProjectNexus.projects
				if project.id is ProjectNexus.selected_project_id
					spi = i
			
			@select ProjectNexus.projects[spi + delta]
		
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
		{projects} = @props
		E ".projects.sidebar",
			E "ul.projects-list",
				for project in projects
					E ProjectListItem, {project}
