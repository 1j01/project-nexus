
class @EditorOfJSON extends React.Component
	constructor: ->
		@state = value: null
	
	render: ->
		# console.log "render"
		E ""
	
	componentDidMount: ->
		# console.log "componentDidMount"
		{value, update, name} = @props
		el = React.findDOMNode(@)
		@editor = new JSONEditor el,
			change: =>
				value = @editor.get()
				# console.log "change", value
				@setState {value}
				update value
			value
		@editor.setName name if name
		# @FIXME: links open in an nw.js window
		# @FIXME: context menu layout (and other styling)
	
	componentDidUpdate: (prev_props)->
		{value} = @props
		# console.log "componentDidUpdate", value, prev_props.value, @state.value, value isnt prev_props.value, value isnt @state.value
		if value isnt prev_props.value and JSON.stringify(value) isnt JSON.stringify(@state.value)
			# console.log "set"
			@editor.set value
	
	componentWillUnmount: ->
		@editor.clear()
