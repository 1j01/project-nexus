
class @PackageDependencies extends React.Component
	render: ->
		{dependencies, field} = @props
		E ".package-dependencies",
			E "table",
				E "tbody",
					for name, version of dependencies
						do (name, version)->
							E "tr",
								E "td",
									name
								E "td",
									E "input.entry",
										value: version # @TODO edit
								E "td",
									E "button.button",
										onClick: (e)=>
											save_flag = switch field
												when "dependencies" then "--save"
												when "devDependencies" then "--save-dev"
												when "optionalDependencies" then "--save-optional"
												else ""
											command = "npm uninstall #{name} #{save_flag}".trim()
											alert "@TODO #{command}"
										E "i.octicon.octicon-x"
					E "tr",
						E "td",
							E "input.entry",
								value: "" # @TODO edit
						E "td",
							E "input.entry",
								value: "" # @TODO edit
								placeholder: "latest"
						E "td",
							E "button.button",
								onClick: (e)=>
									# @TODO: validate input
									save_flag = switch field
										when "dependencies" then "--save"
										when "devDependencies" then "--save-dev"
										when "optionalDependencies" then "--save-optional"
										else ""
									command = "npm install something #{save_flag}".trim()
									alert "@TODO #{command}"
								E "i.octicon.octicon-plus"
