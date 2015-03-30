
gui = require "nw.gui"
win = window.win = gui.Window.get()

{exec, spawn} = require "child_process"

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
	# @TODO: keyboard support
	render: ->
		E "ul.projects",
			for project in @props.projects
				E ProjectListItem, {project}


class ProjectListItem extends Component
	render: ->
		{project} = @props
		{path, fname, pkg} = project
		name = fname
		id = fname
		
		stop = ->
			if project.process
				if pkg.scripts?.stop
					exec "npm stop", cwd: path
				else
					if process.platform is "win32"
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
					"■" # [rotated]
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
				project = {id: fname, fname, path}
				try
					project.package_json_path = join path, "package.json"
					project.package_json = fs.readFileSync project.package_json_path, "utf8"
					project.pkg = JSON.parse project.package_json
				projects.push project
		
		do render
