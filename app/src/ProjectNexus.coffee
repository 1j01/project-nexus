
is_running =  require "is-running"
tree_kill =  require "tree-kill"

kill = ({pid})->
	console.log "kill #{pid}"
	tree_kill pid, 'SIGKILL', (err)->
		return console.error err if err
		console.log "killed #{pid}"
		Settings.update "running_processes", (running_processes)->
			console.log "updating running_processes"
			rproc for rproc in running_processes when rproc.pid isnt pid

class @ProjectNexus extends React.Component
	@projects = null
	@projects_read_error = null
	@selected_project_id = null
	
	render: ->
		if ProjectNexus.projects
			for project in ProjectNexus.projects
				if project.id is ProjectNexus.selected_project_id
					selected_project = project
		
		runaway_processes = ProjectNexus.runaway_processes
		console.log "render ProjectNexus, runaway_processes:", runaway_processes
		
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
					if runaway_processes?.length
						E ".runaway-processes",
							E "h2", "Runaway Processes"
							E "table",
								E "thead",
									E "tr",
										E "th", "Project"
										E "th", "Info"
										E "th", "PID"
										E "th", E "button.button.destructive-action",
											onClick: -> kill rproc for rproc in runaway_processes
											E "GtkLabel", "Kill All"
								E "tbody",
									for rproc in runaway_processes then do (rproc)->
										E "tr.runaway-process", key: rproc.pid,
											E "td", rproc.project_name
											E "td", rproc.info
											E "td", rproc.pid
											E "td", E "button.button.destructive-action",
												onClick: -> kill rproc
												E "GtkLabel", "Kill"
							E "button.button",
								onClick: -> Settings.set "running_processes", []
								E "GtkLabel", "Let 'em run"
				E Settings
