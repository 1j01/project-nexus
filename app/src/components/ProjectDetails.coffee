
fs = require "fs"

class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{pkg, package_json, package_json_path} = project
			update_package_json = (new_json, callback)->
				console.log "Update #{package_json_path}:", new_json
				fs.writeFile package_json_path, new_json, "utf8", (err)->
					if err
						alert "Failed to write to package.json: #{err.stack ? err}"
					else
						# trigger an update because the fs watching in projects-directory.coffee doesn't work
						Settings.update "projects_dir", (projects_dir)-> projects_dir
			E ".project-details",
				if package_json?
					E PackageEditor, {package_json, package_json_path, update_package_json}
				E ".processes",
					for command, proc of project.processes
						E Process, {project, command, process: proc}
			# @TODO: WYSIWYG README.md editor
		else
			E ".project-details.no-project",
				E "h2", "Select a project to get started."
