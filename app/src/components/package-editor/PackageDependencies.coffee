
semver = require "semver"

install_package = ({name, version, exact, field, exec_npm}, callback)=>
	# console.log "install_package", {name, version, exact, field, exec_npm}, callback
	unless name
		alert "No package to install"
		callback no
		return
	if version and not semver.validRange version
		alert "Invalid version string"
		callback no
		return
	save_flag = switch field
		when "dependencies" then "--save"
		when "devDependencies" then "--save-dev"
		when "optionalDependencies" then "--save-optional"
		else ""
	package_to_install =
		if semver.valid version
			"#{name}@#{version}"
		else if version
			"#{name}@\"#{version}\""
		else
			name
	
	npm_subcommand = "install #{package_to_install} #{save_flag}".trim()
	exec_npm npm_subcommand, (err, stderr, stdout)=>
		command = "npm #{npm_subcommand}"
		
		if err
			alert "Failed to exec `#{command}`:\n", err
			console.error "Failed to exec `#{command}`:\n#{err}"
		else if stderr.match /code E404|404 not found/
			alert "Package #{package_to_install} not found"
			console.error "Failed to install #{package_to_install} (not found):\n", stderr
		else if stderr.match /ERR! version not found/
			alert "Version #{version} of package not found"
			console.error "Failed to install #{package_to_install} (version not found):\n", stderr
		else if stderr.match /ERR!/
			alert "Failed to install #{package_to_install}:\n#{stderr}"
			console.error "Failed to install #{package_to_install}:\n", stderr
		
		callback not (err or stderr)


class @PackageDependencyRow extends React.Component
	constructor: ->
		@state =
			uninstalling: no
			reinstalling: no
			version: null
	render: ->
		{uninstalling, reinstalling} = @state
		{name, field, exec_npm} = @props
		version = @state.version ? @props.version
		
		reinstall_different_version = =>
			@setState reinstalling: yes
			install_package {name, version, exact: yes, field, exec_npm}, (success)=>
				@setState
					version: null
					reinstalling: no
				if success
					# trigger an update because the fs watching in projects-directory.coffee doesn't work
					update_projects()
		
		E "tr",
			E "td",
				name
			E "td",
				E "input.entry",
					# class: {error: if @state.version then not semver.valid version else not semver.validRange version}
					class: {error: not semver.validRange version}
					value: version
					onChange: (e)=>
						@setState version: e.target.value
					onKeyDown: (e)=>
						if e.keyCode is 13
							reinstall_different_version()
			E "td",
				if @state.version?
					E "button.button.reinstall-package",
						class: {reinstalling}
						onClick: reinstall_different_version
						E "i.octicon.octicon-zap"
						# E "i.octicon.octicon-#{
						# 	if semver.valid(@state.version) and semver.valid(@props.version)
						# 		if semver.gt @state.version, @props.version then "arrow-up"
						# 		else if semver.lt @state.version, @props.version "arrow-down"
						# 		else "package"
						# 	else "package"
						# }"
						
				else
					E "button.button.uninstall-package",
						class: {uninstalling}
						onClick: (e)=>
							save_flag = switch field
								when "dependencies" then "--save"
								when "devDependencies" then "--save-dev"
								when "optionalDependencies" then "--save-optional"
								else ""
							@setState uninstalling: yes
							exec_npm "uninstall #{name} #{save_flag}".trim(), (err, stderr, stdout)=>
								@setState uninstalling: no
								# console.log err, stderr, stdout
								if err
									alert "Failed to exec `#{command}`:\n#{err}"
									console.error "Failed to exec `#{command}`:\n", err
								else if stderr.match /ERR/
									alert "Failed to uninstall #{name}:\n#{stderr}"
									console.error "Failed to uninstall #{name}:\n", stderr
								else
									update_projects()
						E "i.octicon.octicon-x"


class @PackageDependencies extends React.Component
	constructor: ->
		@state =
			package_name_to_install: ""
			package_version_to_install: ""
			installing: no
	render: ->
		{package_name_to_install, package_version_to_install, installing} = @state
		{dependencies, field, exec_npm} = @props
		
		install_the_package = =>
			# console.log "install_the_package"
			@setState installing: yes
			install_package {
				name: package_name_to_install
				version: package_version_to_install
				field, exec_npm
			},
				(success)=>
					@setState installing: no
					if success
						@setState
							package_name_to_install: ""
							package_version_to_install: ""
						# trigger an update because the fs watching in projects-directory.coffee doesn't work
						update_projects()
		
		E ".package-dependencies",
			E "table",
				E "tbody",
					for name, version of dependencies
						E PackageDependencyRow, {key: name, name, version, field, exec_npm}
					E "tr",
						key: "install new package"
						E "td",
							E "input.entry",
								value: package_name_to_install
								# disabled: installing
								onChange: (e)=>
									@setState package_name_to_install: e.target.value unless installing
								onKeyDown: (e)=>
									if e.keyCode is 13
										install_the_package()
						E "td",
							E "input.entry",
								placeholder: "(latest)"
								value: package_version_to_install
								# disabled: installing
								onChange: (e)=>
									@setState package_version_to_install: e.target.value unless installing
								onKeyDown: (e)=>
									if e.keyCode is 13
										install_the_package()
						E "td",
							E "button.button.install-package",
								class: {installing}
								onClick: install_the_package
								# disabled: installing
								E "i.octicon.octicon-plus"
