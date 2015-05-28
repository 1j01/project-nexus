
prevent = (e)->
	e.preventDefault()
	e.stopPropagation()

window.addEventListener "dragenter", prevent
window.addEventListener "dragover", prevent
window.addEventListener "drop", (e)->
	e.preventDefault()
	dir = e.dataTransfer.files[0].path
	if confirm "Set projects directory to '#{dir}'?"
		Settings.set "projects_dir", dir
