
class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			E ".project-details",
				E ".processes",
					for command, proc of project.processes
						E Process, {project, command, process: proc}
				if package_json?
					E PackageEditor, json: package_json
				else
					E ""
			# @TODO: WYSIWYG README.md editor
		else
			E ".project-details.no-project",
				E "h2", "Select a project to get started."
