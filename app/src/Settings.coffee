
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
	@show: ->
		window.render Settings.open = yes
	
	@hide: ->
		window.render Settings.open = no
	
	@toggle: ->
		window.render Settings.open = not Settings.open
	
	@get: (key)->
		try JSON.parse localStorage.getItem key
		catch e then console.error e
	
	@set: (key, value)->
		try localStorage.setItem key, JSON.stringify value
		catch e then console.error e
		
		for callback in (Settings.watchers[key] ? [])
			callback value
	
	@watchers: {}
	@watch: (key, callback)->
		callback Settings.get key
		Settings.watchers[key] ?= []
		Settings.watchers[key].push callback
	
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
				E ".settings-content",
					E DirectorySetting,
						setting: "projects_dir"
						label: "Projects Directory"
					E CheckboxSetting,
						setting: "list_wrap"
						label: "Enable wrapping in projects list when using keyboard navigation"
					E CheckboxSetting,
						setting: "dark"
						label: "Use dark styles"
					E CheckboxSetting,
						setting: "elementary"
						label: "Use elementary OS's beautiful styles"
