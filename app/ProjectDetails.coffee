
class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			
			E ".project-details",
				E Terminal, {process: project.npm_start_process, id: project.id}
				E "pre", package_json
			# @TODO: package.json editor
			# @TODO: README.md editor
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
