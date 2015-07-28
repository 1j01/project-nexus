
class @PackageDependencies extends React.Component
	render: ->
		{dependencies} = @props
		E ".dependencies",
			E "table",
				E "tbody",
					for name, version of dependencies
						E "tr",
							E "td",
								name
							E "td",
								E "input.entry",
									value: version # @TODO edit
							E "td",
								E "button.button",
									disabled: yes
									onClick: (e)=>
										alert "@TODO npm uninstall #{name} --save"
									E "i.octicon.octicon-x"
									# " Remove"
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
								disabled: yes
								onClick: (e)=>
									alert "@TODO npm install something --save"
								E "i.octicon.octicon-plus"
								# " Install"

class @PackageScripts extends React.Component
	render: ->
		{scripts} = @props
		E ".scripts",
			E "table",
				E "tbody",
					for name, command_line of scripts
						E "tr",
							E "td",
								E "input.entry",
									value: name # @TODO edit
									# @TODO autocomplete with npm search
							E "td",
								E "input.entry",
									value: command_line # @TODO edit
							E "td",
								E "button.button",
									disabled: yes
									onClick: (e)=>
										alert "@TODO update package.json"
									E "i.octicon.octicon-x"
					E "tr",
						E "td",
							E "input.entry",
								value: "" # @TODO edit
						E "td",
							E "input.entry",
								value: "" # @TODO edit
						E "td",
							E "button.button",
								disabled: yes
								onClick: (e)=>
									alert "@TODO update package.json"
								E "i.octicon.octicon-plus"

class @PackageEditor extends React.Component
	ucfirst = (str)-> str.charAt(0).toUpperCase() + str.slice(1)
	isobj = (obj)-> typeof obj is "object" and not (obj instanceof Array)
	render: ->
		{json} = @props
		try
			pkg = JSON.parse json
			fields = ["name", "version", "description"]
			order = ["name", "version", "description"]
			fields = fields.concat (f for f in order when f of pkg and not (f in fields))
			fields = fields.concat (f for f, v of pkg when not (f in fields))
			# @TODO: order "dependencies" fields together near the end
			
			E ".package-editor",
				E "h1",
					E "input.entry.package-name",
						value: pkg.name # @TODO: edit
					E "span", "@"
					E "input.entry.package-version",
						value: pkg.version # @TODO: edit
						# @TODO: custom control with buttons to easily increment the version (major, minor, patch)
						# @TODO: "Publish" button that shows up once you've modified the version field
				for f in fields when not (f in ["name", "version"])
					field_name = (ucfirst f)
						.replace /([a-z])([A-Z])/g, (m, letter1, letter2)-> "#{letter1} #{letter2}"
						.replace /-([a-z])/ig, (m, letter)-> " #{letter.toUpperCase()}"
						.replace /\bDev\b/i, "Development "
						.replace /\bOS\b/i, "OS "
					value = pkg[f]
					if field_name.match /Dependencies/
						E ".field",
							E ".field-name", field_name
							E PackageDependencies, dependencies: value
					else if field_name is "Scripts"
						E ".field",
							E ".field-name", field_name
							E PackageScripts, scripts: value
					else if field_name is "Keywords"
						E ".field",
							E "label",
								E ".field-name", field_name
								E TaggedInput,
									# @TODO: handle editing
									tags: value
									unique: yes
									removeTagLabel: E "i.octicon-x.octicon", style: pointerEvents: "none"
									classes: "entry"
									onFocus: (e)=>
										e.target.parentElement.classList.add "focus"
									onBlur: (e)=>
										e.target.parentElement.classList.remove "focus"
					else
						E ".field",
							E "label",
								E ".field-name", field_name
								if isobj value
									value_json = JSON.stringify(value, null, 2)
									E "textarea.entry",
										value: value_json # @TODO: edit
										rows: value_json.split("\n").length
								else
									E "input.entry", {value} # @TODO: edit
			
			# @TODO: add fields that aren't in package.json already
			# and remove fields
			
		catch err
			E ".package-editor",
				E "pre", "#{err}"
	
	shouldComponentUpdate: (nextProps)->
		nextProps.json isnt @props.json
