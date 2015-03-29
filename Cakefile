
fs = require 'fs'
glob = require 'glob'
NwBuilder = require 'node-webkit-builder'

nw = new NwBuilder
	files: './app/**'
	platforms: ['osx32', 'osx64', 'win32', 'win64', 'linux32', 'linux64']
	version: "0.12.0-rc1"


nw.on 'log', console.log

task 'build', ->
	nw.build()
		.then ->
			console.log '(done build)'
		.catch (error)->
			console.error(error)

task 'run', ->
	nw.run()
		.then ->
			console.log '(done running)'
		.catch (error)->
			console.error error

