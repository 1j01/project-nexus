
Term = Terminal

class @Terminal extends React.Component
	
	# @TODO: persistent terminal sessions
	
	render: ->
		E ".terminal-container"
	
	componentDidMount: ->
		@init() if @props.process
	
	componentDidUpdate: (prev_props)->
		if @props.id isnt prev_props.id
			@term?.destroy()
		if @props.process and @props.process isnt prev_props.process
			@init()
	
	init: ->
		@term?.destroy()
		
		proc = @props.process
		
		term = @term = new Term
			cols: 8
			rows: 2
			screenKeys: on
			convertEol: yes
		
		term.focus = -> # prevent the terminal from recieving focus
		
		container = React.findDOMNode(@)
		term.open container
		@resize_handler = => @resize()
		setTimeout @resize_handler, 50
		window.addEventListener "resize", @resize_handler
		container.addEventListener "transitionend", @resize_handler, no
		
		# @TODO: use https://github.com/chjj/pty.js so more programs will output in color
		
		proc.stdout.on 'data', (data)->
			term.write data
		
		proc.stderr.on 'data', (data)->
			term.write data
	
	resize: ->
		unless @term
			console.log "Terminal::resize, no @term"
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
		
		w = container.clientWidth // tester.clientWidth
		h = container.clientHeight // tester.clientHeight
		console.log "Terminal::resize, #{w}x#{h}"
		
		@term.resize w, h
		
		container.removeChild tester_terminal
		tester_terminal = null
		tester = null
	
	componentWillUnmount: ->
		window.removeEventListener "resize", @resize_handler
		console.log "Terminal: destroying @term"
		@term?.destroy()
		@term = null
