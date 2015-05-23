
{exec, spawn} = require "child_process"
kill_tree = require "tree-kill"

gui = require "nw.gui"
win = window.win = gui.Window.get()

@switch_frame = ->
	setTimeout ->
		elementary = (Settings.get "elementary")
		(require "nw.gui").Window.open location.href,
			toolbar: no
			frame: not elementary
			transparent: elementary
			icon: "app/img/cube.png"
		window.close()
	, 50


links = document.querySelectorAll 'link[rel="stylesheet"]'
update_stylesheets = ->
	for link in links
		if (link.classList.contains "dark") and not (Settings.get "dark")
			link.remove()
		else if (link.classList.contains "light") and (Settings.get "dark")
			link.remove()
		else if (link.classList.contains "elementary") and not (Settings.get "elementary")
			link.remove()
		else
			document.head.appendChild link

Settings.watch "dark", update_stylesheets

Settings.watch "elementary", (elementary)->
	# NOTE: `is not` isn't `isnt`
	# `is not` handles the setting being undefined (not yet set)
	# this let's the application launch properly the first time
	switch_frame() if win.isTransparent == (not elementary)

{join, resolve} = require "path"
fs = require "fs"

require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./app/launchers"
		require "./launchers/#{fname}"

Settings.open = no

do @render = ->
	React.render (React.createElement ProjectNexus), document.body

# @TODO: watch the projects directory for changes (projects added, removed, renamed)
# but don't overwrite the state in the mutated project objects!
# or you know, don't mutate the state

Settings.watch "projects_dir", (projects_dir)->
	ProjectNexus.projects_read_error = null
	
	if not projects_dir
		ProjectNexus.projects = null
		Settings.show()
		render()
		return
	
	projects_dir = resolve projects_dir
	
	fs.readdir projects_dir, (err, fnames)->
		if err
			ProjectNexus.projects_read_error = err
			Settings.show()
			render()
			return
		
		ProjectNexus.projects = []
		for fname in fnames
			path = join projects_dir, fname
			stats = fs.statSync path
			if stats.isDirectory()
				project = {id: fname, dirname: fname, name: fname, path}
				
				do (project)->
					project.processes = {}
					project.exec = (command, info)->
						proc = project.processes[command] = exec command, cwd: project.path
						proc.info = info
						proc.running = yes
						
						{pid} = proc
						Settings.update "running_processes", (running_processes = [])->
							running_processes.push {pid, command, info, project_id: project.id, project_name: project.name}
							running_processes
						
						proc.kill = -> kill_tree proc.pid
						
						proc.on "error", (err)->
							console.error err
							proc.running = no
						
						proc.on "exit", (code, signal)->
							console.log "process #{info} exited with code #{code}"
							proc.running = no
							proc.exitCode = code
							proc.exitSignal = signal
							running_processes = (Settings.get "running_processes") ? []
							Settings.update "running_processes", (running_processes = [])->
								rproc for rproc in running_processes when rproc.pid isnt proc.pid
							window.render()
						
						ProjectNexus.selected_project_id = project.id
						window.render()
						proc
				
				try
					package_json_path = join path, "package.json"
					project.package_json = fs.readFileSync package_json_path, "utf8"
					project.pkg = JSON.parse project.package_json
				
				ProjectNexus.projects.push project
		
		do render

win.show() unless win.shown
win.shown = yes
