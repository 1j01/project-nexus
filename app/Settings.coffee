
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
		@labeled E "input.entry",
			value: @get()
			onChange: (e)=>
				@set e.target.value
				@change? e
				window.render()


class DirectorySetting extends Setting
	render: ->
		@labeled E ".linked",
			E "input.entry",
				type: "text"
				value: @get()
				onChange: (e)=>
					@set e.target.value
					@change? e
					window.render()
				E "button.button",
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


class @Settings extends React.Component
	@show: ->
		window.render Settings.open = yes
	
	@hide: ->
		window.render Settings.open = no
	
	@toggle: ->
		window.render Settings.open = not Settings.open
	
	@get: (key)->
		try JSON.parse localStorage.getItem key
		catch e then console.warn e
	
	@set: (key, value)->
		try localStorage.setItem key, JSON.stringify value
		catch e then console.warn e
	
	render: ->
		# @TODO: escape from settings
		E ".settings-container", class: {visible: Settings.open},
			E ".overlay", onClick: Settings.hide
			E ".settings",
				E "h2",
					E "i.mega-octicon.octicon-gear"
					" Settings"
					E "button",
						style: float: "right"
						onClick: Settings.hide
						E "i.octicon.octicon-x"
				
				# @TODO: auto detect common project superdirectories
				# such as from Github for Windows
				# or simple things like %USER%/Code or ~/code
				E DirectorySetting,
					setting: "projects_dir"
					label: "Projects Directory"
					change: -> window.read_projects_dir()
				E CheckboxSetting,
					setting: "list_wrap"
					label: "Enable wrapping in projects list when using keyboard navigation"
				# @TODO: configure your editor and other applications you want to open
				# allow you to use your EDITOR (by default if you have it set)
				# allow you to set your %EDITOR% with setx on windows
