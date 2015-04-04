
fs = require "fs"
# glob = require "glob"
# readdirp = require "readdirp"
{join} = require "path"
{exec, spawn} = require "child_process"
we_have_to_deal_with_Windows = process.platform is "win32"


locate = (chrome)->
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
				chrome.exe = executable
				break
			else
				console.log "no file at #{executable}"
	else
		chrome.exe = "google-chrome"
		# @TODO: also check for chromium?
		# @TODO: test on linux
		# @TODO: mac support anyone?

chrome =
	open: (url)-> throw "things at me" #reference
	app:
		open: (path)->
			locate chrome
			if chrome.exe
				spawn chrome.exe, ["--load-and-launch-app=#{path}"]
			else
				window.alert "Can't find an executable for Google Chrome."


E = window.ReactScript

module.exports = (project)->
	# readdirp
	# 	root: project.path
	# 	directoryFilter: ["!.git", "!*modules", "!tmp", "!cache", "!build"]
	# .on "data", (entry)->
	# 	if entry.name is "manifest.json"
	# 		console.log entry
	
	# manifest_path = join project.path, "manifest.json"
	# for fname in []#glob.sync project.path + "/**/manifest.json"
	# 	console.log fname
	# 	manifest_path = fname
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
					onClick: ->
						chrome.app.open app_path
					# E "img", src: "img/chrome.svg", style: width: 32, height: 32, color: "inherit"
					# E "img", src: "img/chrome.svg", style: width: 32, height: 32, color: "currentColor"
					# E "svg", src: "img/chrome.svg", style: width: 32, height: 32, color: "currentColor"
					E "i.icon-chrome", style: "-webkit-transform": "scale(0.75)"


# @TODO: also support extensions with --load-extension

