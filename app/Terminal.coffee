
@Term = Terminal

class @Terminal extends React.Component
	
	constructor: ->
		@keep = null
	
	render: ->
		window.addEventListener "resize", => @resize()
		E ".terminal-container"
	
	componentDidMount: -> @handleEverything()
	componentDidUpdate: -> @handleEverything()
	
	handleEverything: ->
		console.log "change from", @id, "to", @props.id
		# @term ?= @props.process?.term
		@term?.element?.remove?() if @props.id isnt @id
		@id = @props.id
		# if @props.id isnt @id # and @props.process?.term isnt @term
		# 	@term?.element?.remove?()
		# 	# @term?.element = null
		# # @term?.element?.remove?() if @props.process and @props.process?.term isnt @term
		@init() if @props.process
	
	init: ->
		# @term?.element?.remove?()
		proc = @props.process
		
		term = proc.term
		term ?= new Term
			cols: 8
			rows: 2
			screenKeys: on
			convertEol: yes
		
		proc.term = term
		@term = term
		
		container = React.findDOMNode(@)
		if term.element
			console.log "appending old term element"
			container.appendChild term.element
			console.log term
		else
			console.log "creating new term element"
			term.open container
		
		@resize()
		# setTimeout resize, 50
		container.addEventListener "transitionend", @resize, no
		
		
		# @TODO: use https://github.com/chjj/pty.js
		# to make the child process feel comfortable showing its true colors
		
		proc.stdout.on 'data', @onStdOut = (data)=> term.write data
		proc.stderr.on 'data', @onStdErr = (data)=> term.write data
		proc.on 'close', @onProcClose = => term.off 'data'
		term.on 'data', @onTermData = (data)=>
			proc.stdin.write data
			@stayOpen = yes
	
	resize: =>
		if not @term
			console.warn "resize, no @term"
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
	
	componentWillUnmount: -> @clean()
	componentWillUpdate: -> @clean()
	
	clean: ->
		container = React.findDOMNode(@)
		container.removeEventListener "transitionend", @resize, no
		
		proc = @props.process
		proc?.stdout.removeListener 'data', @onStdOut
		proc?.stderr.removeListener 'data', @onStdErr
		proc?.removeListener 'close', @onProcClose
		
		@term?.off 'data', @onTermData
		@term?.element?.remove?()
		@term = null
	
	shouldComponentUpdate: (nextProps)->
		# nextProps.id isnt @props.id or
		# nextProps.process isnt @props.process
		nextProps.id isnt @props.id or
		nextProps.process isnt @props.process
