
{Menu, MenuItem} = require "nw.gui"

menu = new Menu
menu.append new MenuItem
	label: "Cut"
	click: -> document.execCommand "cut"
menu.append new MenuItem
	label: "Copy"
	click: -> document.execCommand "copy"
menu.append new MenuItem
	label: "Paste"
	click: -> document.execCommand "paste"

document.addEventListener "contextmenu", (e)->
	e.preventDefault()
	if (
		e.target instanceof HTMLInputElement or
		e.target instanceof HTMLTextAreaElement or
		e.target.isContentEditable
	)
		menu.popup(e.x, e.y)
