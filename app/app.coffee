
gui = require "nw.gui"
win = window.win = gui.Window.get()

{join, resolve} = require "path"
fs = require "fs"

require "coffee-script/register"
launchers =
	for fname in fs.readdirSync "./launchers"
		require "./launchers/#{fname}"

E = ReactScript
{Component} = React

projects = []
projects_read_error = null
active_project_id = null

Settings.open = no

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
					E "i.mega-octicon.octicon-gear"
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
		{id, path, dirname, name, pkg} = project
		
		E "li.project",
			title: path
			class: ("active" if active_project_id is id)
			onClick: -> render active_project_id = id
			E "span.project-name", name
			# project.launchers
			for launcher_module in launchers
				(launcher_module project) ? E "button", disabled: yes, style: pointerEvents: "none"


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



do @render = ->
	el = E App, {
		projects
		projects_read_error
		active_id: active_project_id
	}
	React.render el, document.body


# @TODO: watch this directory
# but don't overwrite the state in the mutated project objects!
do @read_projects_dir = ->
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
				project = {id: fname, dirname: fname, name: fname, path}
				
				try
					package_json_path = join path, "package.json"
					project.package_json = fs.readFileSync package_json_path, "utf8"
					project.pkg = JSON.parse project.package_json
				
				# try
				# 	project.readme_path = join path, "README.md"
				# 	project.readme_md = fs.readFileSync project.readme_path, "utf8"
				
				# index_html = join path, "index.html"
				# if fs.existsSync index_html
				# 	project.index_html = index_html
				
				# project.launchers =
				# 	for launcher_module in launchers
				# 		(launcher_module project) ? E "button", disabled: yes, style: pointerEvents: "none"
				
				projects.push project
		
		do render

win.show()
