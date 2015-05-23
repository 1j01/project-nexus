
is_running =  require "is-running"
kill_tree =  require "tree-kill"

class @ProjectNexus extends React.Component
	@projects = null
	@projects_read_error = null
	@selected_project_id = null
	
	render: ->
		if ProjectNexus.projects
			for project in ProjectNexus.projects
				if project.id is ProjectNexus.selected_project_id
					selected_project = project
		
		running_processes = (Settings.get "running_processes") ? []
		running_processes_new = []
		runaway_processes = []
		for rproc in running_processes
			is_runaway = yes # probably, let's find out
			if ProjectNexus.projects
				for project in ProjectNexus.projects
					for command, proc of project.processes
						if proc.pid is rproc.pid
							is_runaway = no
			if is_runaway
				if is_running rproc.pid
					runaway_processes.push rproc
					running_processes_new.push rproc
				else
					console.log "this process appears to have exited:", rproc
			else
				running_processes_new.push rproc
		
		Settings.set "running_processes", running_processes_new
		
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
					if runaway_processes.length
						E ".runaway-processes",
							E "h2", "Runaway Processes"
							E "table",
								E "thead",
									E "tr",
										E "th", "Project"
										E "th", "Info"
										E "th", "PID"
										E "th", E "button.button.destructive-action",
											onClick: ->
												for rproc in runaway_processes
													kill_tree rproc.pid
											E "GtkLabel", "Kill All"
								E "tbody",
									for rproc in runaway_processes then do (rproc)->
										E "tr.runaway-process", key: rproc.pid,
											E "td", rproc.project_name
											E "td", rproc.info
											E "td", rproc.pid
											E "td", E "button.button.destructive-action",
												onClick: ->
													kill_tree rproc.pid
												E "GtkLabel", "Kill"
				E Settings
