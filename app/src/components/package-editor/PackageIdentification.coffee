
class @PackageVersion extends React.Component
	constructor: ->
		@state = version: null
	render: ->
		version = @state.version ? @props.version
		E ".package-version",
			style:
				position: "relative"
			E "input.entry",
				value: version
				onChange: (e)=>
					@setState version: e.target.value
			if "#{version}".match /^\d+\.\d+\.\d+\b/
				[_, major, minor, patch, after] = version.match /^(\d+)\.(\d+)\.(\d+)\b(.*)/
				segment_strings = [major, minor, patch]
				segments = segment_strings.map (n)-> parseInt n
				x = 8
				for segment, i in segments
					do (segment, i)=>
						segment_string = segment_strings[i]
						this_x = x + (17 * (segment_string.length - 1)) / 2
						x += 10 + 17 * segment_string.length
						E "button.button.increment-version",
							style:
								position: "absolute"
								bottom: -2
								left: this_x
								width: 20
							onClick: (e)=>
								el = React.findDOMNode @
								input = el.querySelector "input"
								segments = for segment, j in segments
									if j is i
										segment + 1
									else if j > i
										0
									else
										segment
								[major, minor, patch] = segments
								@setState version: "#{major}.#{minor}.#{patch}#{after}"
								# @TODO: write to package.json
							E "i.octicon.octicon-plus"
			
			# @TODO: "Publish" button that shows up once you've modified the version field

class @PackageIdentification extends React.Component
	render: ->
		{name, version} = @props
		E "h1.package-identification",
			E "input.entry.package-name",
				value: name # @TODO: edit
			E "span", "@"
			E PackageVersion, {version}
