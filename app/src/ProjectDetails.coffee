
class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			
			E ".project-details",
				E ".processes",
					for command, proc of project.processes then do (command, proc)->
						E ".process",
							E "header",
								E ".process-info", proc.info
								E ".process-exited", "exited with code #{proc.exitCode}" if proc.exitCode?
								E "button.close-process",
									onClick: ->
										proc.kill() if proc.running
										delete project.processes[command]
										window.render()
									E "i.octicon.octicon-x"
							E Terminal, {process: proc, id: project.id}
				if package_json?
					E PackageEditor, json: package_json
				else
					E ""
			# @TODO: WYSIWYG README.md editor
		else
			E ".project-details.no-project",
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
