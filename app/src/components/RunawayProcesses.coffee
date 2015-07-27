
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

class @RunawayProcesses extends React.Component
	render: ->
		{runaway_processes} = @props
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
