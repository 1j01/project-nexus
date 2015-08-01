
latest_versions = {}
{exec} = require "child_process"
{dirname} = require "path"
semver = require "semver"

class @PackageVersion extends React.Component
	constructor: ->
		@state = version: null
	
	render: ->
		package_path = dirname @props.package_json_path
		package_name = @props.name
		is_private = @props.private
		version = @state.version ? @props.version
		
		unless package_name of latest_versions
			unless is_private
				latest_versions[package_name] = "loading..."
				npm_show_version = exec "npm show #{package_name} version"
				npm_show_version_stdout = ""
				npm_show_version_stderr = ""
				npm_show_version.stdout.on "data", (data)-> npm_show_version_stdout += data
				npm_show_version.stderr.on "data", (data)-> npm_show_version_stderr += data
				npm_show_version.on "close", ->
					if npm_show_version_stderr.match /code E404/
						latest_versions[package_name] = null
					else if npm_show_version_stderr.match /\S/
						console.error "Failed to get latest package version for #{package_name}:\n#{npm_show_version_stderr}"
					else
						latest_versions[package_name] = npm_show_version_stdout.trim()
					# @setState {}
					window.render()
		
		latest_publishsed_version = latest_versions[package_name]
		been_publishsed = semver.valid latest_publishsed_version
		not_yet_been_publishsed = latest_publishsed_version is null
		
		E ".package-version",
			style:
				position: "relative"
			E "input.entry",
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
								npm_publish = exec "npm publish", cwd: package_path
								npm_publish_stdout = ""
								npm_publish_stderr = ""
								npm_publish.stdout.on "data", (data)-> npm_publish_stdout += data
								npm_publish.stderr.on "data", (data)-> npm_publish_stderr += data
								npm_publish.on "close", ->
									if npm_publish_stderr
										alert "Failed to publish! Check npm-debug.log for details"
										console.error "Failed to publish #{package_name}@#{version}:\n#{npm_publish_stderr}"
									else
										alert "Published #{package_name}@#{version}!"
						"Publish"
	
	componentDidUpdate: (oldProps, oldState)->
		{update_package} = @props
		if @state.version and @state.version isnt oldState.version
			update_package (pkg)=>
				pkg.version = @state.version
			setTimeout =>
				@setState version: null
			, 400

class @PackageIdentification extends React.Component
	render: ->
		{name, version, update_package} = @props
		E "h1.package-identification",
			E "input.entry.package-name",
				value: name # @TODO: edit
			E "span", "@"
			E PackageVersion, @props # {name, version, private, update_package}
