
gui = require "nw.gui"
win = window.win = gui.Window.get()

{join, resolve} = require "path"
fs = require "fs"

require "coffee-script/register"
@launchers =
	for fname in fs.readdirSync "./launchers"
		require "./launchers/#{fname}"

E = ReactScript

Settings.open = no


do @render = ->
	el = E ProjectNexus
	React.render el, document.body


# @TODO: watch this directory
# but don't overwrite the state in the mutated project objects!
do @read_projects_dir = ->
	projects_dir = Settings.get "projects_dir"
	if not projects_dir
		ProjectNexus.projects_read_error = new Error "No projects directory!"
		Settings.show()
		render()
		return
	
	projects_dir = resolve projects_dir
	
	fs.readdir projects_dir, (err, fnames)->
		ProjectNexus.projects_read_error = err
		if err
			Settings.show()
			render()
			return
		ProjectNexus.projects = []
		for fname in fnames
			path = join projects_dir, fname
			stats = fs.statSync path
			if stats.isDirectory()
				project = {id: fname, dirname: fname, name: fname, path}
				
				try
					package_json_path = join path, "package.json"
					project.package_json = fs.readFileSync package_json_path, "utf8"
					project.pkg = JSON.parse project.package_json
				
				ProjectNexus.projects.push project
		
		do render

win.show()
