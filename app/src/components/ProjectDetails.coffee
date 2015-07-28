
class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			E ".project-details",
				if package_json?
					E PackageEditor, json: package_json
				E ".processes",
					for command, proc of project.processes
						E Process, {project, command, process: proc}
			# @TODO: WYSIWYG README.md editor
		else
			E ".project-details.no-project",
				E "h2", "Select a project to get started."
