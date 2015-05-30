
class @PackageEditor extends React.Component
	ucfirst = (str)-> str.charAt(0).toUpperCase() + str.slice(1)
	isobj = (obj)-> typeof obj is "object" and not (obj instanceof Array)
	render: ->
		{json} = @props
		return E "pre", json
		# @TODO
		try
			pkg = JSON.parse json
			fields = ["name", "version", "description"]
			order = ["name", "version", "description", ]
			fields = fields.concat (f for f in order when f of pkg and not (f in fields))
			fields = fields.concat (f for f, v of pkg when not (f in fields))
			E "form.package-editor",
				for f in fields
					field_name = (ucfirst f)
						.replace "Dev", "Development "
						.replace "Os", "OS"
					value = pkg[f]
					E ".field",
						E "label",
							E ".field-name", field_name
							E "input", value: if isobj value then JSON.stringify(value) else value
		catch err
			E "form.package-editor",
				E "pre", "#{err}"
	
	shouldComponentUpdate: (nextProps)->
		nextProps.json isnt @props.json
