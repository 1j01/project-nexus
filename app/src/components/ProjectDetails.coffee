
# @TODO move all this stuff out of ProjectDetails

{exec, spawn} = require "child_process"
process_tree = require "process-tree"

node_inspector = null

start_node_inspector = (callback)->
	if node_inspector?
		console.log "node-inspector is already running (okay)"
		return
	web_port = 9899
	debug_port = 5858 # the default
	console.log "Start node-inspector"
	args = "--web-port #{web_port} --debug-port #{debug_port}"
	info = "node-inspector #{args}"
	command = "node #{global.require.resolve "node-inspector/bin/inspector"} #{args}"
	node_inspector = exec command
	console.log node_inspector
	
	{pid} = node_inspector
	window.background_processes ?= []
	window.background_processes.push pid
	Settings.update "running_processes", (running_processes = [])->
		running_processes.push {pid, command, info, background: yes}
		running_processes
	
	stdout = ""
	stderr = ""
	node_inspector.stdout.on "data", (data)->
		stdout += data; console.log "Recieved stdout from node-inspector:", data
		if m = data.match /Visit (.*) to start debugging/
			[_, url] = m
			callback null, url
	node_inspector.stderr.on "data", (data)->
		stderr += data; console.log "Recieved stderr from node-inspector:", data
	node_inspector.on "error", callback
	node_inspector.on "close", (code)->
		node_inspector = null
		
		window.background_processes =
			bproc for bproc in window.background_processes when bproc.pid isnt pid
		Settings.update "running_processes", (running_processes = [])->
			rproc for rproc in running_processes when rproc.pid isnt pid
		
		if code
			callback new Error "node-inspector exited with code #{code}:\n#{stderr}"
		else
			console.log "node-inspector exited with code #{code}:\n#{stdout}"
			# callback null, "http://127.0.0.1:#{web_port}/?port=#{debug_port}"

enable_debugging = (pid, callback)->
	if process.platform is "win32"
		console.log "Enable debugging in node process #{pid} by executing process._debugProcess in a new node process"
		cp = spawn "node", ["-e", "process._debugProcess(#{pid})"]
		cp.on "error", callback
		stderr = ""
		cp.stderr.on "data", (data)->
			stderr += data
		cp.on "close", (code)->
			if code
				callback new Error "Process exited with code #{code}:\n#{stderr}"
			else
				callback()
	else
		console.log "Enable debugging in node process #{pid} by sending SIGUSR1"
		process.kill pid, "SIGUSR1"
		process.nextTick callback


class @ProjectDetails extends React.Component
	render: ->
		{project} = @props
		if project
			{package_json} = project
			
			E ".project-details",
				E ".processes",
					for command, proc of project.processes then do (command, proc)->
						E ".process", key: command,
							E "header",
								E ".process-info", proc.info
								if proc.exitCode?
									E ".process-exited", "exited with code #{proc.exitCode}"
								else
									if command.match /^(node(js)?|iojs|npm)(\.exe)?\s/ # hueristic
										E "button.button.icobutton.inspect-with-blink",
											onClick: ->
												if proc.debug_url
													(require "nw.gui").Shell.openExternal proc.debug_url
													# @TODO: instead of opening the url externally,
													# maybe refresh the iframe/webview of the debugger?
													# no, close it
													return
												
												console.log proc.pid, "get children"
												process_tree proc.pid, (err, children)->
													console.log proc.pid, err, children
													process_to_debug = null
													for npm in children when npm.name.match /(node(js)?|iojs|npm)?(\.exe)?$/ # not conhost.exe
														[npm_running_script] = npm.children
														if npm_running_script?.children?.length
															[node_maybe] = npm_running_script.children
															process_to_debug = node_maybe if node_maybe.name.match /(node(js)?|iojs)(\.exe)?$/
													if process_to_debug
														enable_debugging process_to_debug.pid, (err)->
															if err
																console.error "Failed to enable debugging in node process", process_to_debug.pid, "\n", err
															else
																console.log "Debugging enabled for node process #{process_to_debug.pid}"
																start_node_inspector (err, url)->
																	if err
																		console.error "Failed to start node-inspector:\n", err
																	else
																		console.log "Started node-inspector"
																		proc.debug_url = url
																		# @TODO: embed the debugger in an iframe or webview
																		# instead of opening the url externally
																		(require "nw.gui").Shell.openExternal proc.debug_url
																		# window.render()
													else
														console.error "No node process found to debug in children of #{proc.pid}:", children
														alert "No node process found to debug"
													
											E "i.octicon.octicon-bug"
								E "button.button.icobutton.close-process",
									onClick: ->
										if proc.running
											proc.on "exit", ->
												delete project.processes[command]
												window.render()
											proc.kill()
										else
											delete project.processes[command]
											window.render()
									E "i.octicon.octicon-x"
							E Terminal, {process: proc, id: project.id}
							# @TODO: embed the debugger in an iframe or webview
							# an iframe gets content security policy errors
							# and a webview gets nothing (can't debug it)
							# if proc.debug_url
							# 	E "webview", src: proc.debug_url
				if package_json?
					E PackageEditor, json: package_json
				else
					E ""
			# @TODO: WYSIWYG README.md editor
		else
			E ".project-details.no-project",
				style:
					background: "#ccc"
					opacity: 0.4
					alignItems: "center"
					flexDirection: "row"
				E "div",
					style:
						position: "relative"
						margin: "auto"
						textAlign: "center"
						fontSize: "1.5em"
						height: "auto"
					# @TODO: Hey! Lighten up.
					"Hey! Select a damn project."
