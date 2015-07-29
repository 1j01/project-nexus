
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
				E PackageIdentification, name: pkg.name, version: pkg.version
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
							E PackageDependencies, dependencies: value, field: f
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
	
	shouldComponentUpdate: (nextProps)->
		nextProps.json isnt @props.json
