
fs = require "fs"
{join} = require "path"
{spawn} = require "child_process"
we_have_to_deal_with_Windows = process.platform is "win32"


locate = (chrome)->
	# @TODO: also check for chromium?
	if we_have_to_deal_with_Windows
		for dir in [
			# XP (C:\Documents and Settings\UserName\Local Settings\Application Data\Google\Chrome\chrome.exe)
			join process.env.APPDATA, "/Google/Chrome"
			# Vista (C:\Users\UserName\AppDataLocal\Google\Chrome\chrome.exe)
			join process.env.LOCALAPPDATA, "/Google/Chrome"
			# Windows 7 (C:\Users\Username\AppData\Local\Google\chrome.exe)
			join process.env.LOCALAPPDATA, "/Google"
			# Windows 7/8
			# (C:\Program Files (x86)\Google\Application\chrome.exe) (supposedly)
			join process.env["ProgramFiles(x86)"], "/Google/Application/"
			# (C:\Program Files (x86)\Google\Chrome\Application\chrome.exe)
			join process.env["ProgramFiles(x86)"], "/Google/Chrome/Application/"
			# @TODO use the registry?
			# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe
		]
			executable = join dir, "chrome.exe"
			if fs.existsSync executable
				return executable
			else
				console.log "no file at #{executable}"
	else
		# @TODO: test on linux
		"google-chrome"
	
	# @TODO: mac support anyone?

chrome =
	open: (path)->
		if chrome.exe = locate chrome
			spawn chrome.exe, ["--load-and-launch-app=#{path}"]
		else
			window.alert "Can't find an executable for Google Chrome."


E = window.ReactScript

module.exports = (project)->
	# @TODO: look in arbitrary locations for manifest.json
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
				E "button",
					title: "open chrome app (#{manifest_path})"
					onClick: -> chrome.open app_path
					E "i.icon-chrome", style: "-webkit-transform": "scale(0.75)"

# @TODO: also support extensions with --load-extension

