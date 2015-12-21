
fs = require "fs"

prevent = (e)->
	e.preventDefault()
	e.stopPropagation()
	# @TODO/@FIXME: allow drag and drop in inputs/textareas

window.addEventListener "dragenter", prevent
window.addEventListener "dragover", prevent
window.addEventListener "drop", (e)->
	e.preventDefault()
	[file] = e.dataTransfer.files
	if file?
		fs.stat file.path, (err, stats)->
			if stats.isDirectory()
				dir = file.path
				if confirm "Set projects directory to '#{dir}'?"
					Settings.set "projects_dir", dir
