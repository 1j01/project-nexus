
fs = require "fs"
{join} = require "path"

module.exports = (project)->
	start_command = "npm start"
	
	use_npm_stop = project.pkg?.scripts?.stop?
	
	stop = ->
		if use_npm_stop
			project.exec "npm stop"
		else
			project.processes[start_command]?.kill()
	
	if project.pkg
		script_runner = (script, command)->
			run_script_info = "npm run #{script} (#{command})"
			text: script
			title: run_script_info
			action: -> project.exec "npm run #{script}", run_script_info
		
		npm_run_script_menu = (script_runner script, command for script, command of project.pkg.scripts)
	
	# @TODO: keep track of whether the project has been started?
	# This assumes the `npm start` process will
	# stay open as long as you want to `npm stop`
	# so that's probably not very useful
	# but I've never actually used `npm stop`
	# so this is not a priority for me
	if project.processes[start_command]?.running
		
		stop_info =
			if use_npm_stop
				"npm stop (#{project.pkg.scripts.stop})"
			else
				project.processes[start_command].info.replace start_command, "kill"
		
		action: stop
		title: stop_info
		icon: "octicon-primitive-square"
		menu: npm_run_script_menu
		
	else
		if project.pkg
			starter = (start_info)->
				start = ->
					unless project.processes[start_command]?.running
						project.exec start_command, start_info
				
				action: start
				title: start_info
				icon: "octicon-playback-play"
				menu: npm_run_script_menu
			
			if project.pkg.scripts?.start
				starter "#{start_command} (#{project.pkg.scripts.start})"
			else if fs.existsSync (join project.path, "server.js")
				starter "#{start_command} (node server.js)"
			else
				title: "npm run-script ..."
				icon: "octicon-playback-play"
				menu: npm_run_script_menu
			
