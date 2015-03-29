
gui = require "nw.gui"
win = window.win = gui.Window.get()

E = ReactScript
{Component} = React



class App extends Component
	render: ->
		{projects} = @props
		console.log App.active_id
		for p in projects
			active_project = p if p.id is App.active_id
		console.log active_project, projects
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
		{full_path, fname} = project
		name = fname
		id = fname
		
		E "li.project",
			class: ("active" if App.active_id is id)
			title: full_path
			onClick: ->
				App.active_id = id
				console.log App.active_id
				do render
			E "button.start", "▲"
			E "span.project-name", name


class ProjectDetails extends Component
	render: ->
		console.log @props
		{project} = @props
		if project
			{package_json} = project
			E "pre", package_json
		else
			E "div", "Hey! Select a damn project."


projects_dir = "C:\\Users\\Isaiah\\!!Projects\\"

fs = require "fs"
{join} = require "path"

App.active_id = null
projects = []

do render = ->
	React.render (E App, {projects, active_id: App.active_id}), document.body

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
					project.info = JSON.parse project.package_json
				projects.push project
		
		do render
