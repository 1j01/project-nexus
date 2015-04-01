
gui = require "nw.gui"
win = window.win = gui.Window.get()

fs = require "fs"
{join, resolve} = require "path"

{exec, spawn} = require "child_process"
we_have_to_deal_with_Windows = process.platform is "win32"

E = ReactScript
{Component} = React

projects = []
projects_read_error = null
active_project_id = null

settings_open = no

class App extends Component
	render: ->
		{projects, projects_read_error} = @props
		
		for project in projects
			if project.id is active_project_id
				active_project = project
		
		E "div.app",
			E "header",
				E "h1", "Project Nexus"
				E "button",
					onClick: Settings.show
					title: "@TODO: gear icon"
					"Settings"
			E "main",
				E ProjectsList, {projects, projects_read_error}
				E ProjectDetails, project: active_project
			E Settings


class ProjectsList extends Component
	constructor: ->
		go = (delta)->
			for project, i in projects
				if project.id is active_project_id
					active_project_i = i
			
			active_project_i += delta
			
			activate = (project)->
				if project
					active_project = project
					active_project_id = project.id
					render()
					# document.querySelector(".active.project").scrollIntoView()
					document.querySelector(".active.project").scrollIntoViewIfNeeded()
			
			if Settings.get "list_wrap"
				activate projects[active_project_i %% projects.length]
			else
				activate projects[active_project_i]
		
		window.addEventListener "keydown", (e)->
			# console.log e.keyCode
			switch e.keyCode
				when 38 then go -1 # up
				when 40 then go +1 # down
				else return
			e.preventDefault()
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


class ProjectListItem extends Component
	render: ->
		{project} = @props
		{id, path, dirname, pkg} = project
		name = dirname
		
		if pkg?.scripts?.stop
			stop = ->
				exec "npm stop", cwd: path
				return
		else
			stop = ->
				if project.process
					if we_have_to_deal_with_Windows
						spawn "taskkill", ["/pid", project.process.pid, "/f", "/t"]
					else
						project.process.kill()
				return
		
		# @TODO: multiple commands
		if pkg
			start_command = "npm start"
			
			start_info =
				if pkg.scripts?.start
					"#{start_command} (#{pkg.scripts.start})"
				else
					start_command
			
			start = ->
				unless project.process
					render project.process = exec start_command, cwd: path
					project.process.on "exit", (code, signal)->
						render project.process = null
					# @TODO: handle/display process output
				return
			
		else if project.index_html
			# @TODO: HTTP server
			# @TODO: Live reload
			start = ->
				gui.Shell.openExternal "file://#{project.index_html}"
			start_info = "open index.html"
		else
			start_info = "no start command"
		
		E "li.project",
			title: path
			class: ("active" if active_project_id is id)
			onClick: -> render active_project_id = id
			if project.process
				E "button.stop",
					onClick: stop
					disabled: not project.process
					title: start_info.replace "npm start", "kill"
					"■"
			else
				E "button.start",
					onClick: start
					disabled: not start
					title: start_info
					# @TODO: find a better triangle
					"▲" # {rotated}
			E "span.project-name", name


class ProjectDetails extends Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			E "pre", package_json
			# @TODO: full terminal
			# @TODO: package.json editor
			# @TODO: README.md editor
		else
			E "div",
				style:
					background: "#ccc"
					opacity: 0.4
					alignItems: "center"
					flexDirection: "row"
				E "div",
					style:
						position: "relative"
						margin: "auto"
						textAlign: "center"
						fontSize: "1.5em"
						height: "auto"
					# @TODO: Hey! Lighten up.
					"Hey! Select a damn project."


class Settings
	@show: ->
		render settings_open = yes
	
	@hide: ->
		render settings_open = no
	
	@get: (key)->
		try JSON.parse localStorage.getItem key
		catch e then console.warn e
	
	@set: (key, value)->
		try localStorage.setItem key, JSON.stringify value
		catch e then console.warn e
	
	render: ->
		# labeled = (label, el)->
		# 	E "label",
		# 		"#{label}:"
		# 		el
		
		text_input = (setting, label, onChange)->
			# labeled label,
			E "label.setting",
				"#{label}:"
				E "input",
					value: Settings.get setting
					onChange: (e)=>
						Settings.set setting, e.target.value
						onChange?()
						render()
		
		checkbox = (setting, label, onChange)->
			# labeled label,
			E "label.setting",
				E "input",
					type: "checkbox"
					checked: Settings.get setting
					onChange: (e)=>
						Settings.set setting, e.target.checked
						onChange?()
						render()
				label
		
		E ".settings-container", class: {visible: settings_open},
			E ".overlay", onClick: Settings.hide
			E ".settings",
				text_input "projects_dir", "Projects Directory", read_projects_dir
				checkbox "list_wrap", "Enable wrapping in projects list when using keyboard navigation"
				# @TODO: close button

do render = ->
	el = E App, {
		projects
		projects_read_error
		active_id: active_project_id
	}
	React.render el, document.body


# @TODO: watch this directory
# but don't overwrite the state in the project objects!
do read_projects_dir = ->
	projects_dir = Settings.get "projects_dir"
	if not projects_dir
		projects_read_error = new Error "No projects directory!"
		Settings.show()
		render()
		return
	
	projects_dir = resolve projects_dir
	
	fs.readdir projects_dir, (err, fnames)->
		projects_read_error = err
		if err
			Settings.show()
			render()
			return
		projects = []
		for fname in fnames
			path = join projects_dir, fname
			stats = fs.statSync path
			if stats.isDirectory()
				project = {id: fname, dirname: fname, path}
				try
					project.package_json_path = join path, "package.json"
					project.package_json = fs.readFileSync project.package_json_path, "utf8"
					project.pkg = JSON.parse project.package_json
				try
					project.readme_path = join path, "README.md"
					project.readme_md = fs.readFileSync project.readme_path, "utf8"
				index_html = join path, "index.html"
				if fs.existsSync index_html
					project.index_html = index_html
				projects.push project
		
		do render

win.show()
