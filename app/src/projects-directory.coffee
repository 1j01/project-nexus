
fs = require "fs"
{join, resolve} = require "path"
{exec} = require "child_process"
chokidar = require "chokidar"
kill_tree = require "tree-kill"

update_projects = (projects_dir)->
	global.watcher?.close?()
	global.watcher = null
	
	ProjectNexus.projects_read_error = null
	
	if not projects_dir
		ProjectNexus.projects = null
		render()
		return
	
	projects_dir = resolve projects_dir
	
	fs.readdir projects_dir, (err, fnames)->
		if err
			ProjectNexus.projects_read_error = err
			render()
			return
		
		# @TODO: Watch... deeper? Why isn't this recursive? Why aren't any events firing other than "raw"?
		global.watcher = chokidar.watch projects_dir, ignored: /node_modules|[\/\\]\./
		global.watcher.on "raw", -> update_projects projects_dir
		global.watcher.on "error", (err)-> console.error "chokidar error watching projects directory:", err
		
		old_projects = ProjectNexus.projects
		ProjectNexus.projects = []
		for fname in fnames
			path = join projects_dir, fname
			stats = fs.statSync path
			if stats.isDirectory()
				id = fname
				# @TODO: embrace immutability
				project = null
				for old_project in old_projects ? [] when old_project.id is id
					project = old_project
				project ?= {id}
				project.dirname = fname
				project.name = fname
				project.path = path
				
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

Settings.watch "projects_dir", update_projects
