
### Project Nexus

# Ideas


* Open all your tools for you when you press the folder button
	* Editor
		* Your editor *does* support opening folders, doesn't it?
		* Default to `EDITOR`
		* Ask if you want to set `EDITOR`
			* (`setx` on Windows?)
	* Source control
		* Github for Windows/Mac
		* Various Git GUI clients
		* Command prompt / terminal
		* Integrate a git gui?
			* Someone please make [this](http://tonsky.me/blog/reinventing-git-interface/) a reality
	* Configure whatever tools you want
	* Configure whether you want it to give you
		* an open/close project button, or
		* an open/focus project button (and what it would focus?)
		* and whether you want it to allow multiple projects open
		* Hopefully it can keep track of processes well enough
			* I'm thinking it would be bad if you navigate away from a project within a tool
			  and close the project and the tool is killed even though it's no longer related to the project
				* I guess it would just have to warn you
					* And because of this, murderous behavior would be disabled by default
		* (If one workflow is obviously superior, I'll remove the setting)


* Plugins
	* Make the API asynchronous, and maybe even smarter
	  (most things will be checking for the existence of files,
	  so something that would check once and then watch the file system would be great)
	* Task launchers (with dropdowns)
		* `cake`
		* `make`
		* `rake`
		* `grunt`
		* `gulp`
	* Let plugins add project openers for tools
		* Such as, when there's a solution (.sln) file,
		  it could open Visual Studio
			* In this case, it should override your Editor
	* An interface to install plugins through `npm`


* Link to repository (defined in `package.json`, or through `npm repo`)
	* A way to update `package.json` with repository info


* Visual package editor
	* Help text for known fields
	* Edit arbitrary data
	* Manage dependencies
		* Install and remove packages
		* See `npm outdated` information and easily update packages
		* Edit package versions to downgrade
	* Reusable component / separate project?


* WYSIWYG readme editor
	* Markdown is cool and all, but it's not as good as any WYSIWYG editor
	* Standalone, but integrated project: **WYSIWYG.md**
		* This could also be used in wikis, etc.
			* I want to make a wiki thing called kiwiki
				* The logo would be a [kiwi crossed with a kiwi](https://www.google.com/search?tbm=isch&hl=en&q=kiwi+bird+fruit)
					* But I digress...
		* Keeps your indentation and formatting


* Context sensitive helpers based on process output
	* "Cannot find module"?
		* If the module isn't listed as a dependency, maybe you want to `npm install --save` it?
		* Otherwise, maybe you need to `npm install`?
			* Actually, it could detect that you need to `npm install` proactively
	* "Listening on port 3000"? (and similar)
		* Would you like me to open that for you?
	* "EADDRINUSE"? Not sure I can help with that...
		* I can find an open port, but then what?
			* Monkey patch your code to use a different port? That would be awesome, but **awful**.
			* Suggest a port? (bit lame)
			* Suggest you use a module for finding an open port
		* I don't think there's a way to find what program is using the port
	* Linkify URLs


* Live reload everything
	* Chrome apps
	* `npm start`
	* Automatically run `npm prepublish` upon file changes
		* Also watch linked dependencies
			* Changing a file in the linked dependency might
			  trigger an auto-`prepublish`
			  and this should trigger an auto-`prepublish`
			  of the dependent project only once the dependent project's `prepublish` has finished.
			  Is it possible to detect an npm script being run? Probably not.
			  At any rate, it's probably good enough just to have a delay.
			* Unwatch unlinked dependencies
		* Also watch bundled dependencies
		* Make a package to watch packages, and use it here and in nw-dev
	* Toggle live reload with a checkbox on the process view header
	* **Except** when it already auto-reloads
		* (such as project-nexus does with nw-dev)
		* It *could* try to detect things like nw-dev,
		  but that's not a good solution
		  and this might need to be something you configure
		  (per project)


* elementary OS app
	* Publish to [elementary apps](http://quassy.github.io/elementary-apps/)
	  (and the App Center when it exists in the future)


* The properly capitalized name of a project is
  secretly often stored in... README.md!
	* e.g. `# Project Nexus`
	* (with formatting that would need to be removed of course)
	* and other text file formats


* Better project organization (e.g. folders or groups or tags)


* Hide columns that are displaying no launchers (again!)
	* This was broken by using elementary's sidebar styles which can't exactly work with tables


* Filterable projects list
	* Should this be just type to search or should there be a search bar at the top of the application?
	  (or both?)


* Styles
	* Options for using the native titlebar or not, and if not, what titlebutton layout to use
		* Remove these options when possible
			* Detect the operating system and act accordingly
			* Can I look in some file to see the system button layout in linux?
	* elementary
		* Icons as images
		* Text probably shouldn't all get grayed out like that when the window isn't in focus
		* Settings window looks silly
	* Animation
		* Info bars
		* ProjectDetails
	* Apply `:hover` and `:active` styles with classes
		* Chrome fails to use :hover if you mouse over something with the mouse button down
		* The launcher buttons should stay pressed when the menu is open
	* **Accessibility**
		* Use the entire app with the keyboard
		* A keyboard shortcut for `npm restart` like <kbd>Ctrl</kbd>+<kbd>R</kbd> would be particularly nice
