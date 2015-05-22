
Term = Terminal

class @Terminal extends React.Component
	
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
		# console.log "Terminal::init(), destroy @term"
		@term?.destroy()
		
		proc = @props.process
		
		term = new Term
			cols: 8
			rows: 2
			screenKeys: on
			convertEol: yes
		
		
		container = React.findDOMNode(@)
		term.open container
		do resize = => @resize()
		setTimeout resize, 50
		window.addEventListener "resize", resize
		container.addEventListener "transitionend", resize, no
		
		
		# @TODO: use https://github.com/chjj/pty.js
		
		proc.stdout.on 'data', (data)=>
			term.write data
		
		proc.stderr.on 'data', (data)=>
			term.write data
		
		term.on 'data', (data)=>
			proc.stdin.write data
		
		proc.on 'close', =>
			term.off 'data'
		
		
		# @TODO: persist terminals
		# proc.term = term
		@term = term
	
	resize: ->
		if not @term
			console.log "resize, no @term"
			return
		
		container = React.findDOMNode(@)
		
		# @FIXME transitions interfere with sizing
		
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
