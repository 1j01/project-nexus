
class @TitleButton extends React.Component
	render: ->
		E "button.button.titlebutton",
			onClick: =>
				@props.action?()
				@props.onClick?()
			if @props.icon
				E ".e-icon-#{@props.icon}"
			else
				@props.children
