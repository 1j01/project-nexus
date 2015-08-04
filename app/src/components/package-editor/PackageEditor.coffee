
{exec} = require "child_process"
{dirname} = require "path"

class @PackageEditor extends React.Component
	ucfirst = (str)-> str.charAt(0).toUpperCase() + str.slice(1)
	isobj = (obj)-> typeof obj is "object" and not (obj instanceof Array)
	render: ->
		{package_json, package_json_path, update_package_json} = @props
		
		package_path = dirname @props.package_json_path
		
		exec_npm = (npm_subcommand, callback)->
			
			command = "npm #{npm_subcommand}"
			
			# callback ?= (err, stderr, stdout)->
			# 	if err
			# 		console.error "Failed to exec `#{command}`:\n", err
			# 	else if stderr
			# 		console.error "Error from child process `#{command}`:\n", stderr
			# 	else
			# 		alert "Executed `#{command}` successfully"
			
			npm = exec command, cwd: package_path
			stdout = ""
			stderr = ""
			npm.stdout.on "data", (data)-> stdout += data
			npm.stderr.on "data", (data)-> stderr += data
			npm.on "error", callback
			npm.on "close", ->
				callback null, stderr, stdout
				# @TODO: if command.match /--save/ ...?
		
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
			E PackageIdentification, {name: pkg.name, version: pkg.version, private: pkg.private, update_package, exec_npm}
			for field in fields when not (field in ["name", "version"])
				field_name = (ucfirst field)
					.replace /([a-z])([A-Z])/g, (m, letter1, letter2)-> "#{letter1} #{letter2}"
					.replace /-([a-z])/ig, (m, letter)-> " #{letter.toUpperCase()}"
					.replace /\bDev\b/i, "Development "
					.replace /\bOS\b/i, "OS "
				value = pkg[field]
				E ".field",
					key: "field-#{field_name}"
					if field_name.match /Dependencies/
						[
							E ".field-name", field_name
							E PackageDependencies, {dependencies: value, field, exec_npm}
						]
					else if field_name is "Scripts"
						[
							E ".field-name", field_name
							E PackageScripts, {scripts: value, update_package}
						]
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
					else
						E "label",
							E ".field-name", field_name
							if isobj value
								value_json = JSON.stringify(value, null, 2)
								E "textarea.entry",
									rows: value_json.split("\n").length
									value: value_json # @TODO: edit
							else
								E "input.entry", {value} # @TODO: edit
			
			# @TODO: add, remove and reorder fields
			# or don't allow reordering fields, and just find a good order
	
	shouldComponentUpdate: (nextProps)->
		nextProps.package_json isnt @props.package_json or
		nextProps.update_package_json isnt @props.update_package_json
