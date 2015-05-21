
fs = require "fs"
{join} = require "path"
{spawn} = require "child_process"

chrome =
	exe: require "chrome-location"
	open: (path)->
		if chrome.exe
			spawn chrome.exe, ["--load-and-launch-app=#{path}"]
		else
			window.alert "Can't find an executable for Google Chrome."


E = window.ReactScript

module.exports = (project)->
	# @TODO: look in arbitrary locations for manifest.json
	launcher_button = null
	for subdir in ["", "app"]
		do (subdir)->
			app_path = join project.path, subdir
			manifest_path = join app_path, "manifest.json"
			
			try
				manifest_json = fs.readFileSync manifest_path, "utf8"
				manifest = JSON.parse manifest_json
			
			if manifest?.app
				project.manifest_json = manifest_json
				project.manifest = manifest
				open_it = "open chrome app (#{manifest_path})"
				
				launcher_button =
					action: -> chrome.open app_path
					disabled: not chrome.exe
					title:
						if chrome.exe then open_it else """
							can't #{open_it}
							couldn't find an executable for Google Chrome
						"""
					icon: "icon-chrome"
	
	launcher_button

# @TODO: also support extensions with --load-extension

