
fs = require "fs"
{join, resolve} = require "path"

get_port = require "get-port"

module.exports = (project)->
	if fs.existsSync (join project.path, "index.html")
		action: ->
			get_port (err, port)->
				return console.error err if err
				serve = resolve "./node_modules/live-server/live-server"
				project.exec "node #{serve} #{project.path} --port=#{port}", "live-server"
		title: "open index.html"
		icon: "octicon-globe"
