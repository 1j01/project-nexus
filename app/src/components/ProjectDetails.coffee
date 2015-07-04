
# ps_tree = require "ps-tree"

class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			
			E ".project-details",
				E ".processes",
					for command, proc of project.processes then do (command, proc)->
						E ".process", key: command,
							E "header",
								E ".process-info", proc.info
								if proc.exitCode?
									E ".process-exited", "exited with code #{proc.exitCode}"
								# else
								# 	if command.match /^(node(js)?|iojs|npm)(\.exe)?\s/ # hueristic
								# 		E "button.button.icobutton.inspect-with-blink",
								# 			onClick: ->
								# 				console.log proc.pid, "get children"
								# 				ps_tree proc.pid, (err, children)->
								# 					console.log proc.pid, err, children
								# 			E "i.octicon.octicon-bug"
								E "button.button.icobutton.close-process",
									onClick: ->
										if proc.running
											proc.on "exit", ->
												delete project.processes[command]
												window.render()
											proc.kill()
										else
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
