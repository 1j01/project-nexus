
fs = require "fs"
{join, resolve} = require "path"
pkg = require "../package.json"

name = pkg.window?.title ? pkg.name

if process.platform is "win32"

	programs_folder = join process.env.APPDATA, "Microsoft", "Windows", "Start Menu", "Programs"
	program_folder = join programs_folder, name
	shortcut_file = join program_folder, "#{name}.lnk"
	try fs.unlinkSync shortcut_file
	try fs.rmdirSync program_folder
	
else if process.platform is "darwin"
	
	# @TODO (Hey, do you have a Mac? Wanna help?)
	# Maybe look at how nw-init does it?
	
else
	
	applications_folder = "/usr/share/applications"
	desktop_file = join applications_folder, "io.github.1j01.project-nexus.desktop"
	try fs.unlinkSync desktop_file
