
class @ProjectListItem extends React.Component
	render: ->
		{project} = @props
		{id, path, dirname, name, pkg} = project
		
		E "li.project",
			title: path
			class: ("active" if ProjectNexus.selected_project_id is id)
			onClick: -> window.render ProjectNexus.selected_project_id = id
			
			E "button",
				onClick: -> (require "nw.gui").Shell.openItem path
				E "i.mega-octicon.octicon-file-directory"
			
			E "span.project-name", name
			
			for launcher_module in launchers
				E Launcher, launcher_module project
