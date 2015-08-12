
latest_versions = {}
semver = require "semver"

class @PackageVersion extends React.Component
	constructor: ->
		@state = version: null, published: no
	
	render: ->
		{published} = @state
		{exec_npm} = @props
		package_name = @props.name
		is_private = @props.private
		version = @state.version ? @props.version
		
		unless package_name of latest_versions
			unless is_private
				latest_versions[package_name] = "loading..."
				
				exec_npm "show #{package_name} version", (err, stderr, stdout)->
					if err
						console.error "Failed to exec `npm show #{package_name} version`:\n", err
					else if stderr.match /code E404|404 Not Found/
						latest_versions[package_name] = null
					else if stderr.match /ERR/
						console.error "Failed to get latest package version for #{package_name}:\n#{stderr}"
					else
						latest_versions[package_name] = stdout.trim()
					
					# @setState {}
					window.render()
		
		latest_publishsed_version = latest_versions[package_name]
		been_publishsed = semver.valid latest_publishsed_version
		not_yet_been_publishsed = latest_publishsed_version is null
		
		E ".package-version",
			style:
				position: "relative"
			E "input",
				key: "version-input"
				value: version
				onChange: (e)=>
					@setState version: e.target.value
			if "#{version}".match /^\d+\.\d+\.\d+\b/
				[_, major, minor, patch, after] = version.match /^(\d+)\.(\d+)\.(\d+)\b(.*)/
				segment_strings = [major, minor, patch]
				segments = segment_strings.map (n)-> parseInt n
				x = 8
				for segment, i in segments
					do (segment, i)=>
						segment_name = ["major", "minor", "patch"][i]
						segment_string = segment_strings[i]
						this_x = x + (17 * (segment_string.length - 1)) / 2
						x += 10 + 17 * segment_string.length
						E "button.button.increment-version",
							key: "increment-version-#{segment_name}"
							style:
								position: "absolute"
								bottom: -2
								left: this_x
								width: 20
							onClick: (e)=>
								el = React.findDOMNode @
								input = el.querySelector "input"
								segments = for segment, j in segments
									if j is i
										segment + 1
									else if j > i
										0
									else
										segment
								[major, minor, patch] = segments
								@setState version: "#{major}.#{minor}.#{patch}#{after}"
							E "i.octicon.octicon-plus"
			
			# console.log {package_name, is_private, not_yet_been_publishsed, been_publishsed, version, latest_publishsed_version}
			unless is_private
				if not_yet_been_publishsed or (been_publishsed and semver.gt(version, latest_publishsed_version))
					E "button.button.publish",
						key: "publish"
						onClick: (e)=>
							if confirm "Publish #{package_name}@#{version}?"
								latest_versions[package_name] = "publishing"
								exec_npm "publish", (err, stderr, stdout)=>
									if err
										alert "Failed to publish! Error executing `npm publish`:\n#{err.stack}"
										console.error "Failed to publish #{package_name}@#{version}:\n", err
									else if stderr
										alert "Failed to publish! Check npm-debug.log for details"
										console.error "Failed to publish #{package_name}@#{version}:\n#{stderr}"
									else
										latest_versions[package_name] = version
										@setState published: version
										# a hidden setting just for me
										if Settings?.get? "copy_to_clipboard_on_npm_publish"
											window._previous_clipboard = _gui.Clipboard.get().get()
											_gui.Clipboard.get().set "+ #{package_name}@#{version}!"
						"Publish"
				else if published
					E ".published",
						"Published!"
	
	componentDidUpdate: (oldProps, oldState)->
		{update_package} = @props
		if @state.version and @state.version isnt oldState.version
			update_package (pkg)=>
				pkg.version = @state.version
			setTimeout =>
				@setState version: null
			, 400
			@setState published: no

class @PackageIdentification extends React.Component
	constructor: ->
		@state = name: null
	render: ->
		{version, update_package} = @props
		name = @state.name ? @props.name
		edit_name = (e)=>
			# console.log e.target, e.target?.textContent
			# @setState name: e.target.textContent #, html: e.target.innerHTML
			# # setTimeout =>
			# # 	@setState name: e.target.textContent, html: e.target.innerHTML
			# # , 5
			e.target.textContent = e.target.textContent
			# @TODO: handle editing
		E "h1.package-identification",
			# E "input.package-name",
			# 	value: name
			E "div.input.package-name",
				key: Math.random()
				contentEditable: "true"
				style: display: "inline-block"
				onKeyDown: edit_name
				onPaste: edit_name
				onCut: edit_name
				onInput: edit_name
				onBlur: edit_name
				name
			E "span", "@"
			E PackageVersion, @props # {name, version, private, update_package}
	
	# componentDidMount: -> @sizePackageNameInput()
	# componentDidUpdate: -> @sizePackageNameInput()
	# sizePackageNameInput: ->
	# 	el = React.findDOMNode @
	# 	input = el.querySelector "input.package-name"
	# 	input.style.width = "#{input.}px"
	
	# componentDidUpdate: ->
	# 	el = React.findDOMNode @
	# 	contenteditable_package_name = el.querySelector ".input.package-name"
	# 	contenteditable_package_name.textContent = @state.name
	# 	return
