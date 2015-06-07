
fs = require "fs"
{join} = require "path"
HOME = require "user-home"
Windows = process.platform is "win32"
Mac = process.platform is "darwin"

class @WelcomeScreen extends React.Component
	render: ->
		default_github_dir = join HOME, "Documents", "Github"
		E "GraniteWidgetsWelcome.welcome-screen",
			E "h1.h1", "Select Your Projects Directory"
			E "GtkLabel", "Where do you keep your project folders?"
			E "button.button",
				onClick: ->
					chooser = document.createElement "input"
					chooser.setAttribute "type", "file"
					chooser.setAttribute "nwdirectory", "nwdirectory"
					chooser.addEventListener "change", (e)=>
						Settings.set "projects_dir", e.target.value
						window.render()
					chooser.click()
				E "img", src: (if Windows then "img/explorer.png" else "img/files.png"), width: 48, height: 48
				E "",
					style: flexDirection: "column"
					E "h3.h3", if Windows then "Browse" else "Find"
					E "GtkLabel", "Choose your projects folder."
			if fs.existsSync default_github_dir
				E "button.button",
					onClick: -> Settings.set "projects_dir", default_github_dir
					E "img", src: "img/github.png", width: 48, height: 48
					E "",
						style: flexDirection: "column"
						E "h3.h3", "Github for #{if Mac then "Mac" else "Windows"}"
						E "GtkLabel", default_github_dir
			# @TODO: keyboard support (up/down arrows)
