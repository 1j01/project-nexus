
objectAssign = (target, sources...)->
	if not target?
		throw new TypeError "Object.assign cannot be called with null or undefined as the target"
	to = Object(target)
	for from in sources
		to[k] = v for k, v of Object(from)
	to


class Setting extends React.Component
	constructor: ({@setting, @label})->
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
					window.render()
			@label


class TextSetting extends Setting
	render: ->
		@labeled E "input.entry",
			value: @get()
			onChange: (e)=>
				@set e.target.value
				window.render()


class DirectorySetting extends Setting
	render: ->
		@labeled E ".linked",
			E "input.entry",
				type: "text"
				value: @get()
				onChange: (e)=>
					@set e.target.value
					window.render()
				E "button.button",
					onClick: =>
						chooser = document.createElement "input"
						chooser.setAttribute "type", "file"
						chooser.setAttribute "nwdirectory", "nwdirectory"
						chooser.addEventListener "change", (e)=>
							@set e.target.value
							window.render()
						chooser.click()
					"Browse"


class @Settings extends React.Component
	
	@open: no
	@show: -> window.render Settings.open = yes
	@hide: -> window.render Settings.open = no
	@toggle: -> window.render Settings.open = not Settings.open
	
	@get: (key)->
		try JSON.parse window.localStorage.getItem key
		catch e then console.error e
	
	@set: (key, value)->
		try window.localStorage.setItem key, JSON.stringify value
		catch e then console.error e
		
		for callback in (Settings.watchers[key] ? [])
			callback value
	
	@update: (key, fn)->
		Settings.set key, fn(Settings.get key)
	
	@watchers: {}
	@watch: (key, callback)->
		callback Settings.get key
		Settings.watchers[key] ?= []
		Settings.watchers[key].push callback
	
	render: ->
		elementary = Settings.get "elementary"
		E ".settings-container", class: {visible: Settings.open}, key: "settings",
			E ".overlay", onClick: Settings.hide
			E ".settings",
				E "h2",
					style: textAlign: "center" if elementary
					E "i.mega-octicon.octicon-gear"
					" Settings"
					E "button.button.icobutton",
						onClick: Settings.hide
						style: float: if elementary then "left" else "right"
						if elementary # (as if these icons were considerably different)
							E "i.e-icon-close"
						else
							E "i.octicon.octicon-x"
				E ".settings-content",
					E DirectorySetting,
						setting: "projects_dir"
						label: "Projects Directory"
					E CheckboxSetting,
						setting: "dark"
						label: "Use dark styles"
					E CheckboxSetting,
						setting: "elementary"
						label: "Emulate elementary OS's window frame"
	
	componentDidMount: ->
		window.addEventListener "keydown", @keydown_listener = (e)->
			if e.keyCode is 27 # Escape
				Settings.hide()
	
	componentWillUnmount: ->
		window.removeEventListener "keydown", @keydown_listener
