
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
				E TitleButton,
					action: Settings.toggle
					E "i.mega-octicon.octicon-gear"
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
							E ProjectsList, projects: projects
							E ProjectDetails, project: selected_project
						]
					else
						E WelcomeScreen
					
					# @TODO: move this into a new component
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
											E "td", rproc.project_name ? if rproc.background then E "i", "(Background)"
											E "td", rproc.info
											E "td", rproc.pid
											E "td", E "button.button.destructive-action",
												onClick: -> kill rproc
												E "GtkLabel", "Kill"
							E "button.button",
								onClick: -> Settings.set "running_processes", []
								E "GtkLabel", "Let 'em run"
				E Settings
