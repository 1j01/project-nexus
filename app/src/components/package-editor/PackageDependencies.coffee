
class @PackageDependencies extends React.Component
	constructor: ->
		@state =
			package_name_to_install: ""
			package_version_to_install: ""
			installing: no
	render: ->
		{package_name_to_install, package_version_to_install, installing} = @state
		{dependencies, field, exec_npm} = @props
		
		install_package = (e)=>
			# @TODO: validate input
			unless package_name_to_install
				alert "No package to install"
				return
			save_flag = switch field
				when "dependencies" then "--save"
				when "devDependencies" then "--save-dev"
				when "optionalDependencies" then "--save-optional"
				else ""
			package_to_install = if package_version_to_install then "#{package_name_to_install}@#{package_version_to_install}" else package_name_to_install
			@setState installing: yes
			exec_npm "install #{package_to_install} #{save_flag}".trim(), (err, stderr, stdout)=>
				@setState installing: no
				console.log err, stderr, stdout
				if err
					alert "Failed to exec `#{command}`:\n", err
					console.error "Failed to exec `#{command}`:\n#{err}"
				else if stderr.match /code E404/
					alert "Package #{package_to_install} not found"
					console.error "Failed to install #{package_to_install} (not found):\n", stderr
				else if stderr
					alert "Failed to install #{package_to_install}:\n#{stderr}"
					console.error "Failed to install #{package_to_install}:\n", stderr
				else
					@setState
						package_name_to_install: ""
						package_version_to_install: ""
					# trigger an update because the fs watching in projects-directory.coffee doesn't work
					update_projects()
		
		E ".package-dependencies",
			E "table",
				E "tbody",
					for name, version of dependencies
						# @TODO: PackageDependency component
						do (name, version)->
							E "tr",
								E "td",
									name
								E "td",
									E "input.entry",
										value: version # @TODO edit
								E "td",
									E "button.button.uninstall-package",
										# @TODO: class: {installing}
										onClick: (e)=>
											save_flag = switch field
												when "dependencies" then "--save"
												when "devDependencies" then "--save-dev"
												when "optionalDependencies" then "--save-optional"
												else ""
											# @TODO: @setState uninstalling: yes
											exec_npm "uninstall #{name} #{save_flag}".trim(), (err, stderr, stdout)=>
												# @TODO: @setState uninstalling: no
												console.log err, stderr, stdout
												if err
													alert "Failed to exec `#{command}`:\n#{err}"
													console.error "Failed to exec `#{command}`:\n", err
												else if stderr
													alert "Failed to uninstall #{name}:\n#{stderr}"
													console.error "Failed to uninstall #{name}:\n", stderr
												else
													update_projects()
										E "i.octicon.octicon-x"
					E "tr",
						E "td",
							E "input.entry",
								value: package_name_to_install
								# disabled: installing
								onChange: (e)=>
									@setState package_name_to_install: e.target.value unless installing
								onKeyDown: (e)=>
									if e.keyCode is 13
										install_package()
						E "td",
							E "input.entry",
								placeholder: "(latest)"
								value: package_version_to_install
								# disabled: installing
								onChange: (e)=>
									@setState package_version_to_install: e.target.value unless installing
								onKeyDown: (e)=>
									if e.keyCode is 13
										install_package()
						E "td",
							E "button.button.install-package",
								class: {installing}
								onClick: install_package
								# disabled: installing
								E "i.octicon.octicon-plus"
