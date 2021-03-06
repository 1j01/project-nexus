
latest_versions = {}
semver = require "semver"

class @PackageVersion extends React.Component
	render: ->
		{version, exec_npm, update_package} = @props
		package_name = @props.name
		is_private = @props.private
		
		CHECKING_NPM = "checking npm..."
		
		unless package_name of latest_versions
			unless is_private
				latest_versions[package_name] = CHECKING_NPM
				
				exec_npm "show #{package_name} version", (err, stderr, stdout)->
					if err
						console.error "Failed to exec `npm show #{package_name} version`:\n", err
					else if stderr.match /code E404|404 Not Found/
						latest_versions[package_name] = null
					else if stderr.match /ERR/
						console.error "Failed to get latest package version for #{package_name}:\n#{stderr}"
					else
						latest_versions[package_name] = stdout.trim()
					
					window.render()
		
		latest_published_version = latest_versions[package_name]
		has_been_published = semver.valid latest_published_version
		not_yet_been_published = latest_published_version is null
		this_version_is_published = has_been_published and latest_published_version is version
		
		E ".package-version",
			style:
				position: "relative"
			E "input",
				key: "version-input"
				value: version
				onChange: (e)=>
						# FIXME: cursor moves to end of input
						# because rerender doesn't occur immediately
					update_package (pkg)=>
						pkg.version = e.target.value
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
								
								update_package (pkg)=>
									pkg.version = "#{major}.#{minor}.#{patch}#{after}"
								
							E "i.octicon.octicon-plus"
			
			unless is_private
				if semver.valid(version) and (not_yet_been_published or (has_been_published and semver.gt(version, latest_published_version)))
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
										window.render()
										# a hidden setting just for me
										if Settings?.get? "copy_to_clipboard_on_npm_publish"
											window._previous_clipboard = nw.Clipboard.get().get()
											nw.Clipboard.get().set "+ #{package_name}@#{version}"
						"Publish"
				else if this_version_is_published
					E "a.published",
						href: "https://www.npmjs.com/package/#{package_name}"
						target: "_blank"
						"published"
				else if latest_published_version is CHECKING_NPM
					E "span.checking-if-published",
						CHECKING_NPM

class @PackageName extends React.Component
	render: ->
		{name, update_package} = @props
		E "input.input.package-name",
			value: name
			onChange: (e)=>
				# FIXME: cursor moves to end of input
				# because rerender doesn't occur immediately
				update_package (pkg)=>
					pkg.name = e.target.value
	
	resize: ->
		input = React.findDOMNode(@)
		tester = document.createElement "span"
		tester.className = input.className
		tester.innerText = input.value
		input.parentElement.insertBefore tester, input
		input.style.width = "#{tester.clientWidth}px"
		input.parentElement.removeChild tester
	
	componentDidUpdate: -> @resize()
	componentDidMount: -> setTimeout => @resize()

class @PackageIdentification extends React.Component
	render: ->
		E "h1.package-identification",
			E PackageName, @props
			E "span.at", "@"
			E PackageVersion, @props
