
Term = Terminal

class @Terminal extends React.Component
	
	render: ->
		window.addEventListener "resize", => @resize()
		E ".terminal-container"
	
	componentDidMount: ->
		@init() if @props.process
	
	componentDidUpdate: (prev_props)->
		if @props.project.path isnt prev_props.project.path
			@term?.destroy()
		if @props.process
			@init()
	
	init: ->
		@term?.destroy()
		# \x1b[2J\x1b[1;1H
		
		proc = @props.process
		
		term = new Term
			cols: 8
			rows: 2
			screenKeys: true
		
		term.on 'data', (data)=>
			proc.stdin.write data
		
		term.on 'title', (title)=>
			console.log "got title", title
			document.title = title
		
		term.open React.findDOMNode(@)
		@resize()
		setTimeout =>
			console.log @
			@resize()
		, 50
		
		# term.write '\x1b[31mWelcome to term.js!\x1b[m\r\n'
		
		
		proc.stdout.on 'data', (data)=>
			term.write data.replace /\n/g, "\n\r" # + "\r"
		
		proc.stderr.on 'data', (data)=>
			term.write data.replace /\n/g, "\n\r" # + "\r"
			# term.write "\x1b[31m#{data}\x1b[m".replace /\n/g, "\n\r" # + "\r"
		
		# proc.on 'disconnect', =>
		# 	term.destroy()
		
		# socket.on 'data', (data)=>
		# 	term.write(data)
		#
		# socket.on 'disconnect', =>
		# 	term.destroy()
		
		# proc.term = term
		@term = term
		
	
	resize: ->
		if not @term
			console.log "resize, no @term"
			return
		
		container = React.findDOMNode(@)
		
		tester_terminal = document.createElement "div"
		tester_terminal.className = "terminal"
		container.appendChild tester_terminal
		
		tester_div = document.createElement "div"
		tester_div.className = "terminal"
		tester_terminal.appendChild tester_div
		
		tester = document.createElement "span"
		tester.className = "terminal"
		tester.style.display = "inline-block"
		tester.style.width = "auto"
		tester.innerText = "#"
		tester_div.appendChild tester
		
		console.log "resize",
			container.clientWidth // tester.clientWidth
			container.clientHeight // tester.clientHeight
		
		@term.resize(
			container.clientWidth // tester.clientWidth
			container.clientHeight // tester.clientHeight
		)
		
		container.removeChild tester_terminal
		tester_terminal = null
		tester = null
	
	componentWillUnmount: ->
		console.log "destroying term"
		@term?.destroy()
		@term = null
