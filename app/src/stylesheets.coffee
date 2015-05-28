
links = document.querySelectorAll 'link[rel="stylesheet"]'
update_stylesheets = ->
	for link in links
		if (link.classList.contains "dark") and not (Settings.get "dark")
			link.remove()
		else if (link.classList.contains "light") and (Settings.get "dark")
			link.remove()
		else if (link.classList.contains "elementary") and not (Settings.get "elementary")
			link.remove()
		else
			document.head.appendChild link

@switch_frame = ->
	setTimeout ->
		elementary = (Settings.get "elementary")
		(require "nw.gui").Window.open location.href,
			toolbar: no
			frame: not elementary
			transparent: elementary
			icon: "app/img/cube.png"
		window.close()
	, 50

Settings.watch "dark", update_stylesheets

Settings.watch "elementary", (elementary = no)->
	switch_frame() if win.isTransparent is not elementary
