
Windows = process.platform.match /win/

class @WelcomeScreen extends React.Component
	render: ->
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
				# E "GtkLabel", "Browse"
				E "img", src: (if Windows then "img/explorer.png" else "img/files.png"), width: 48, height: 48
				E "",
					style: flexDirection: "column"
					E "h3.h3", if Windows then "Browse" else "Find"
					E "GtkLabel", "Choose your projects folder."
