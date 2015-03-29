
gui = require "nw.gui"
win = window.win = gui.Window.get()

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
	render: ->
		E "ul.projects",
			for project in @props.projects
				E ProjectListItem, {project}


class ProjectListItem extends Component
	render: ->
		{project} = @props
		{full_path, fname, pkg} = project
		name = fname
		id = fname
		
		if pkg
			start_command = "npm start"
			
			start_info =
				if pkg.scripts?.start
					"#{start_command} (#{pkg.scripts.start})"
				else
					start_command
			
			start = ->
				{exec} = require "child_process"
				exec start_command, cwd: full_path
			
		else
			start_info = "no start command"
		
		
		E "li.project",
			title: full_path
			class: ("active" if active_project_id is id)
			onClick: -> render active_project_id = id
			E "button.start",
				onClick: start
				disabled: not start
				title: start_info
				"▲" # rotated
			E "span.project-name", name


class ProjectDetails extends Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			E "pre", package_json
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
					"Hey! Select a damn project."

projects_dir = "C:\\Users\\Isaiah\\!!Projects\\"

fs = require "fs"
{join} = require "path"

projects = []

do render = ->
	React.render (E App, {projects, active_id: active_project_id}), document.body

do read_projects_dir = ->
	fs.readdir projects_dir, (err, fnames)->
		projects = []
		for fname in fnames
			full_path = join projects_dir, fname
			stats = fs.statSync full_path
			if stats.isDirectory()
				project = {id: fname, fname, full_path}
				try
					project.package_json_path = join full_path, "package.json"
					project.package_json = fs.readFileSync project.package_json_path, "utf8"
					project.pkg = JSON.parse project.package_json
				projects.push project
		
		do render
