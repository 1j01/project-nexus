
fs = require "fs"
{join} = require "path"
HOME = require "user-home"
Windows = process.platform is "win32"
Mac = process.platform is "darwin"

class @WelcomeScreen extends React.Component
	render: ->
		# @TODO: Detect common project superdirectories from popular IDEs or other tools?
		
		possible_dir_names = [
			"Code", "Coding", "Programs", "Programming", "Projects"
			"Coding Projects", "Code Projects", "Programming Projects"
			"Coding-Projects", "Code-Projects", "Programming-Projects"
		]
		possible_dir_names = possible_dir_names.concat (dir_name.toLowerCase() for dir_name in possible_dir_names)
		HOME_folder = fs.readdirSync HOME
		
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
						E "h3.h3", "GitHub Desktop"
						E "GtkLabel", default_github_dir
			for dir_name in possible_dir_names when dir_name in HOME_folder
				do (dir_name)->
					possible_project_dir = join HOME, dir_name
					E "button.button",
						onClick: -> Settings.set "projects_dir", possible_project_dir
						E "img", src: (if Windows then "img/windows-folder.png" else "img/files.png"), width: 48, height: 48
						E "",
							style: flexDirection: "column"
							E "h3.h3", "This folder here"
							E "GtkLabel", possible_project_dir
	
	componentDidMount: ->
		el = React.findDOMNode @
		[buttons...] = el.querySelectorAll "button"
		go = (delta)->
			i = buttons.indexOf document.activeElement
			if i is -1
				buttons[0].focus()
			else
				buttons[Math.min(buttons.length - 1, Math.max(0, i + delta))].focus()
		document.body.addEventListener "keydown", @keydown_listener = (e)=>
			switch e.keyCode
				when 38 then go -1 # up
				when 40 then go +1 # down
				else return
			e.preventDefault()
	
	componentWillUnmount: ->
		document.body.removeEventListener "keydown", @keydown_listener
