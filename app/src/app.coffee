
{exec, spawn} = require "child_process"
we_have_to_deal_with_Windows = process.platform is "win32"

gui = require "nw.gui"
win = window.win = gui.Window.get()

@switch_frame = ->
	setTimeout ->
		elementary = (Settings.get "elementary")
		(require "nw.gui").Window.open location.href,
			toolbar: no
			frame: not elementary
			transparent: elementary
		window.close()
	, 50

# note: `is not` isnt `isnt`
# `is not` handles the setting being undefined (not yet set)
# this let's the application launch properly the first time
if win.isTransparent is not Settings.get "elementary"
	return switch_frame()

links = document.querySelectorAll 'link[rel="stylesheet"]'
update_stylesheets = ->
	for link in links when link.className.match /application|elementary/
		if (link.classList.contains "dark") and not (Settings.get "dark")
			console.log "remove dark link", link, "because dark theme is disabled"
			link.remove()
		else if (link.classList.contains "elementary") and not (Settings.get "elementary")
			console.log "remove elementary link", link, "because elementary theme is disabled"
			link.remove()
		else
			document.head.appendChild link

Settings.watch "elementary", update_stylesheets
Settings.watch "dark", update_stylesheets
	# for link in document.querySelectorAll "link.dark"
	# 	link.remove()
	# 
	# document.getElementById("elementary.css").remove()

{join, resolve} = require "path"
fs = require "fs"

require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./app/launchers"
		require "./launchers/#{fname}"

Settings.open = no

do @render = ->
	React.render (React.createElement ProjectNexus), document.body

# @TODO: watch this directory
# but don't overwrite the state in the mutated project objects!
do @read_projects_dir = ->
	ProjectNexus.projects_read_error = null
	
	projects_dir = Settings.get "projects_dir"
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
						if we_have_to_deal_with_Windows
							proc.kill = -> spawn "taskkill", ["/pid", proc.pid, "/f", "/t"]
						proc.on "error", (err)->
							console.error err
							proc.running = no
						proc.on "exit", (code, signal)->
							console.log "process #{info} exited with code #{code}"
							# delete project.processes[command]
							proc.running = no
							proc.exitCode = code
							proc.exitSignal = signal
							window.render()
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
