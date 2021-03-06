
async = require "async"
is_running = require "is-running"

is_under_control = (pid)->
	if window.background_processes?
		if pid in window.background_processes
			return yes
	if ProjectNexus.projects
		for project in ProjectNexus.projects
			for command, proc of project.processes
				if proc.pid is pid
					console.log "#{pid} is owned by #{project.name}:", proc
					return yes
	return no

prevent_recursion = off
Settings.watch "running_processes", (running_processes = [])->
	console.log "watching running_processes", running_processes, "prevent recursion?", prevent_recursion
	return prevent_recursion = off if prevent_recursion
	
	running_processes_new = []
	runaway_processes = []
	async.each running_processes,
		(rproc, callback)->
			if is_under_control rproc.pid
				running_processes_new.push rproc
				callback null
			else
				is_running rproc.pid, (err, rproc_is_running)->
					return callback err if err
					if rproc_is_running
						console.log "this process is still running:", rproc
						running_processes_new.push rproc
						runaway_processes.push rproc
					else
						console.log "this process appears to have exited:", rproc
					callback null
		(err)->
			return console.error err if err
			console.log "running:", running_processes_new
			console.log "runaway:", runaway_processes
			prevent_recursion = on
			Settings.set "running_processes", running_processes_new
			prevent_recursion = off
			ProjectNexus.runaway_processes = runaway_processes
			window.render()
