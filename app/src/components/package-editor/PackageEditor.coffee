
{exec} = require "child_process"
{dirname} = require "path"

class @PackageFieldJSONInput extends React.Component
	render: ->
		{field, value, update_package} = @props
		update = (new_value)->
			update_package (pkg)->
				pkg[field] = new_value
		E EditorOfJSON, {value, update, name: field}

class @PackageFieldInput extends React.Component
	constructor: ->
		@state = text: null
	render: ->
		{field, value, update_package} = @props
		text = @state.text ? value
		E "input.entry",
			value: text
			onChange: (e)=>
				@setState text: e.target.value
				# @TODO: get rid of all these setTimeouts and make update_package show the update immediately
				setTimeout =>
					@setState text: null
				, 400
				update_package (pkg)=>
					pkg[field] = e.target.value

class @PackageFieldCheckbox extends React.Component
	constructor: ->
		@state = checked: null
	render: ->
		{field, value, update_package} = @props
		checked = @state.text ? value
		E "input",
			type: "checkbox"
			checked: checked
			onChange: (e)=>
				@setState checked: e.target.checked
				setTimeout =>
					@setState checked: null
				, 400
				update_package (pkg)=>
					pkg[field] = e.target.checked

class @PackageEditor extends React.Component
	ucfirst = (str)-> str.charAt(0).toUpperCase() + str.slice(1)
	isobj = (obj)-> typeof obj is "object" and not (obj instanceof Array)
	render: ->
		{package_json, package_json_path, update_package_json} = @props
		
		package_path = dirname @props.package_json_path
		
		exec_npm = (npm_subcommand, callback)->
			
			command = "npm #{npm_subcommand}"
			
			npm = exec command, cwd: package_path
			stdout = ""
			stderr = ""
			npm.stdout.on "data", (data)-> stdout += data
			npm.stderr.on "data", (data)-> stderr += data
			npm.on "error", callback
			npm.on "close", ->
				callback null, stderr, stdout
		
		try
			pkg = JSON.parse package_json
		catch e
			return E ".package-editor",
				E "h1", style: padding: 15, "Error parsing package.json"
				E "pre.error", style: marginTop: 50, "#{e}"
		
		update_package = (modify, callback)->
			modify pkg
			new_json = "#{JSON.stringify pkg, null, 2}\n"
			update_package_json new_json, (err)->
				callback? err
		
		fields = ["name", "version", "description"]
		order = ["name", "version", "description"]
		fields = fields.concat (field for field in order when field of pkg and not (field in fields))
		fields = fields.concat (field for field, v of pkg when not (field in fields))
		# @TODO: order "dependencies" fields together near the end
		
		E ".package-editor",
			E PackageIdentification, {key: "name", name: pkg.name, version: pkg.version, private: pkg.private, update_package, exec_npm}
			for field in fields when not (field in ["name", "version"])
				field_name = (ucfirst field)
					.replace /([a-z])([A-Z])/g, (m, letter1, letter2)-> "#{letter1} #{letter2}"
					.replace /-([a-z])/ig, (m, letter)-> " #{letter.toUpperCase()}"
					.replace /\bDev\b/i, "Development "
					.replace /\bOS\b/i, "OS "
				value = pkg[field]
				E ".field",
					key: "field-#{field_name}"
					if field_name.match(/Dependencies/) and not field_name.match(/Bundle/)
						E "",
							E ".field-name", field_name
							E PackageDependencies, {dependencies: value, field, exec_npm}
					# else if field_name is "Scripts"
					# 	E "",
					# 		E ".field-name", field_name
					# 		E PackageScripts, {scripts: value, update_package}
					else if field_name is "Keywords"
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
					else if isobj value
						E "",
							E ".field-name", field_name
							E PackageFieldJSONInput, {field, value, update_package}
					else
						E "label",
							E ".field-name", field_name
							if typeof value is "boolean"
								E PackageFieldCheckbox, {field, value, update_package}
							else
								E PackageFieldInput, {field, value, update_package}
			
			# @TODO: add, remove and reorder fields
			# or don't allow reordering fields, and just find a good order
	
	shouldComponentUpdate: (nextProps)->
		nextProps.package_json isnt @props.package_json or
		nextProps.update_package_json isnt @props.update_package_json
