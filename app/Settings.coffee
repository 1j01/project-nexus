
E = ReactScript

objectAssign = (target, sources...)->
	if not target?
		throw new TypeError "Object.assign cannot be called with null or undefined as the target"
	to = Object(target)
	for from in sources
		to[k] = v for k, v of Object(from)
	to


class Setting extends React.Component
	constructor: ({@setting, @label, @change})->
		super
	labeled: (el)->
		E "label.setting",
			"#{@label}:"
			el
	get: ->
		Settings.get @setting
	set: (val)->
		Settings.set @setting, val


class CheckboxSetting extends Setting
	render: ->
		E "label.setting",
			E "input",
				type: "checkbox"
				checked: @get()
				onChange: (e)=>
					@set e.target.checked
					@change? e
					window.render()
			@label


class TextSetting extends Setting
	render: ->
		@labeled E "input",
			value: @get()
			onChange: (e)=>
				@set e.target.value
				@change? e
				window.render()


# class DirectoryInput extends React.Component
# 	render: ->
# 		E "input", objectAssign {}, @props, {type: "file"}
# 	
# 	componentDidMount: ->
# 		React.findDOMNode(@).setAttribute "nwdirectory", "nwdirectory"


class DirectorySetting extends Setting
	render: ->
		@labeled [
			E "input",
				type: "text"
				value: @get()
				onChange: (e)=>
					@set e.target.value
					@change? e
					window.render()
			# E DirectoryInput,
			# 	# value: @get()
			# 	onChange: (e)=>
			# 		@set e.target.value
			# 		@change? e
			# 		window.render()
				E "button",
					onClick: =>
						chooser = document.createElement "input"
						chooser.setAttribute "type", "file"
						chooser.setAttribute "nwdirectory", "nwdirectory"
						chooser.addEventListener "change", (e)=>
							@set e.target.value
							@change? e
							window.render()
						chooser.click()
					"Browse"
		]


class @Settings
	@show: ->
		window.render Settings.open = yes
	
	@hide: ->
		window.render Settings.open = no
	
	@get: (key)->
		try JSON.parse localStorage.getItem key
		catch e then console.warn e
	
	@set: (key, value)->
		try localStorage.setItem key, JSON.stringify value
		catch e then console.warn e
	
	render: ->
		E ".settings-container", class: {visible: Settings.open},
			E ".overlay", onClick: Settings.hide
			E ".settings",
				E DirectorySetting,
					setting: "projects_dir"
					label: "Projects Directory"
					change: -> window.read_projects_dir()
				E CheckboxSetting,
					setting: "list_wrap"
					label: "Enable wrapping in projects list when using keyboard navigation"
				# @TODO: close button
