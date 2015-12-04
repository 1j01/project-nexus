
class @PackageScripts extends React.Component
	render: ->
		{scripts} = @props
		E ".package-scripts",
			E "table",
				E "tbody",
					for name, command_line of scripts
						E "tr",
							key: name
							E "td",
								E "input.entry",
									value: name, readOnly: yes # @TODO edit
									# @TODO autocomplete with npm search
							E "td",
								E "input.entry",
									value: command_line, readOnly: yes # @TODO edit
							E "td",
								E "button.button",
									onClick: (e)=>
										alert "@TODO update package.json"
									E "i.octicon.octicon-x"
					E "tr",
						key: "(new)"
						E "td",
							E "input.entry",
								value: "", readOnly: yes # @TODO edit
						E "td",
							E "input.entry",
								value: "", readOnly: yes # @TODO edit
						E "td",
							E "button.button",
								onClick: (e)=>
									alert "@TODO update package.json"
								E "i.octicon.octicon-plus"
			
			# @TODO: reorder scripts
