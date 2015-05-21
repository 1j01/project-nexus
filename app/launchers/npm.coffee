
fs = require "fs"
{join} = require "path"
{exec, spawn} = require "child_process"
we_have_to_deal_with_Windows = process.platform is "win32"

E = window.ReactScript

module.exports = (project)->
	start_command = "npm start"
	
	use_npm_stop = project.pkg?.scripts?.stop?
	
	stop = ->
		if use_npm_stop
			exec "npm stop", cwd: project.path
		else
			if project.npm_start_process
				if we_have_to_deal_with_Windows
					spawn "taskkill", ["/pid", project.npm_start_process.pid, "/f", "/t"]
				else
					project.npm_start_process.kill()
		return
	
	
	# @TODO: keep track of whether the project has been started?
	# This assumes the `npm start` process will
	# stay open as long as you want to `npm stop`
	# so that's probably not very useful
	# but I've never actually used `npm stop`
	# so this is not a priority for me
	if project.npm_start_process
		
		stop_info =
			if use_npm_stop
				"npm stop (#{project.pkg.scripts.stop})"
			else
				project.npm_start_process.info.replace start_command, "kill"
		
		action: stop
		title: stop_info
		icon: "octicon-primitive-square"
		
	else
		if project.pkg
			
			start_info =
				if project.pkg.scripts?.start
					"#{start_command} (#{project.pkg.scripts.start})"
				else
					start_command
			
			start = ->
				unless project.npm_start_process
					project.npm_start_process = exec start_command, cwd: project.path
					project.npm_start_process.info = start_info
					window.render()
					project.npm_start_process.on "exit", (code, signal)->
						project.npm_start_process = null
						window.render()
				return
			
			action: start
			title: start_info
			icon: "octicon-playback-play"
