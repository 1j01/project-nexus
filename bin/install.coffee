
fs = require "fs"
{join, resolve} = require "path"
pkg = require "../package.json"

name = pkg.window?.title ? pkg.name
{description} = pkg

icon =
	ico: resolve "app/img/cube.ico"
	png: resolve "app/img/cube.png"

nw = (require "nw").findpath()
nw_app_dir = process.cwd()

if process.platform is "win32"
	
	shortcuts = try require "windows-shortcuts"
	
	if shortcuts?
		
		programs_folder = join process.env.APPDATA, "Microsoft", "Windows", "Start Menu", "Programs"
		program_folder = join programs_folder, name
		try fs.mkdirSync program_folder
		shortcut_file = join program_folder, "#{name}.lnk"
		
		shortcuts.create shortcut_file,
			target: nw
			args: nw_app_dir
			desc: description
			icon: icon.ico
	
else if process.platform is "darwin"
	
	# @TODO (Hey, do you have a Mac? Wanna help?)
	# Maybe look at how nw-init does it?
	
else
	
	desktop_entry = """
		[Desktop Entry]
		Name=#{name}
		GenericName=Project Manager
		Comment=#{description}
		Exec=project-nexus
		Icon=#{icon.png}
		Type=Application
		# MimeType=text/plain;
		Categories=Development;
		# StartupNotify=true
		Terminal=false
		NoDisplay=false
	"""
	applications_folder = "#{process.env.HOME}/.local/share/applications"
	desktop_file = join applications_folder, "io.github.1j01.project-nexus.desktop"
	fs.writeFileSync desktop_file, desktop_entry, "utf8"
