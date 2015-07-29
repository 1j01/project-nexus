
class @PackageVersion extends React.Component
	render: ->
		{version} = @props
		E ".package-version",
			style:
				position: "relative"
			E "input.entry",
				value: version # @TODO: edit
			if "#{version}".match /^\d+\.\d+\.\d+\b/
				for _segment, i in ["major", "minor", "patch"]
					do (_segment, i)=>
						E "button.button.increment-version",
							style:
								position: "absolute"
								bottom: -2
								left: i * 27 + 8
								width: 20
								# left: i * 27 + 16
								# width: 10
								# height: 10
								# bottom: 5
								# @TODO: account for variable-width version segments (multiple digits)
							onClick: (e)=>
								el = React.findDOMNode @
								input = el.querySelector "input"
								console.log version = input.value
								[_, major, minor, patch, after] = version.match /^(\d+)\.(\d+)\.(\d+)\b(.*)/
								console.log [major, minor, patch] + " (from version)"
								segments = [major, minor, patch].map (n)-> parseInt n
								console.log segments + " (mapped to parseInt)"
								# segments[j] = 0 for j in [i+1..segments.length-1]
								# segments[i] += 1
								segments = for segment, j in segments
									if j is i
										segment + 1
									else if j > i
										0
									else
										segment
								console.log segments + " (modified)"
								[major, minor, patch] = segments
								console.log "#{major}.#{minor}.#{patch}#{after}"
								# @TODO: @setState
								input.value = "#{major}.#{minor}.#{patch}#{after}"
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
