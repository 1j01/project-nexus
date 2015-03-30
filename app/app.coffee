
gui = require "nw.gui"
win = window.win = gui.Window.get()

{exec, spawn} = require "child_process"
we_have_to_deal_with_Windows = process.platform is "win32"

E = ReactScript
{Component} = React

active_project_id = null

class App extends Component
	render: ->
		{projects} = @props
		
		for project in projects
			if project.id is active_project_id
				active_project = project
		
		E "div.app",
			E "header", "Project Nexus"
			E "main",
				E ProjectsList, projects: projects
				E ProjectDetails, project: active_project


class ProjectsList extends Component
	constructor: ->
		go = (delta)->
			for project, i in projects
				if project.id is active_project_id
					active_project_i = i
			active_project_i += delta
			if "wrapping" is "cool"
				active_project = projects[active_project_i %% projects.length]
				render active_project_id = active_project.id
			else
				active_project = projects[active_project_i]
				if active_project
					render active_project_id = active_project.id
		
		window.addEventListener "keydown", (e)->
			# console.log e.keyCode
			switch e.keyCode
				when 38 then go -1 # up
				when 40 then go +1 # down
	render: ->
		E "ul.projects",
			for project in @props.projects
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

# @TODO: configuration
projects_dir = "C:\\Users\\Isaiah\\!!Projects\\"

fs = require "fs"
{join} = require "path"

projects = []

do render = ->
	React.render (E App, {projects, active_id: active_project_id}), document.body

# @TODO: watch this directory
# but don't overwrite the state in the project objects!
do read_projects_dir = ->
	fs.readdir projects_dir, (err, fnames)->
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
