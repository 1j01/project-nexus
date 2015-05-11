
### Project Nexus

# Ideas


* Open all your tools for you
	* Like a tool belt conveyor belt or something
	* Editor
		* Your editor *does* support opening folders, doesn't it?
		* Default to `EDITOR`
		* Ask if you want to set `EDITOR`
	* Source control
		* Github for Windows/Mac
		* Various Git GUI clients
		* Command line `git`
		* Integrate Ungit?
			* Ungit is kinda ugly (and doesn't fit in very well)
				* I'm sure it could be themed, to some extent
			* [This](http://tonsky.me/blog/reinventing-git-interface/) is what I really want
	* Folder browser
		* Done. It launches your default folder browser.
	* Configure whatever tools you want
	* Configure whether you want it to give you
		* an open/focus project button
		* an open/close project button
	* and whether you want it to allow multiple projects open
	* Hopefully it can keep track of processes well enough
		* I'm thinking it would be bad if you navigate away from a project within a tool and the tool is killed
			* I guess it would just have to warn you
				* And because of this, murderous behavior would be disabled by default
	* (If one workflow is obviously superior, maybe I can remove the setting)


* Plugins
	* Launch multiple tasks (with dropdowns)
		* npm
		* cake
		* make
		* rake
	* Plugins can add project openers for tools
		* Such as, when there's a solution (.sln) file,
		  it could open Visual Studio
			* This should override your Editor (i.e. not launch both)


* Link to repository (defined in package.json)
	* Context menu with option to update repository info in package.json


* Visual package editor
	* Help text for known fields
	* Keeps your indentation and formatting (even though npm doesn't)
	* Reusable component


* WYSIWYG readme editor
	* Standalone, but integrated project: **WYSIWYG.md**
	* Markdown is cool and all, but it's not as good as any WYSIWYG editor
	* Keeps your indentation and formatting


* Context sensitive helpers based on process output
	* "Cannot find module"?
		* Maybe you need to `npm install`?
		* If the module isn't listed as a dependency, maybe you want to `npm install --save` it?
	* "Listening on port 3000"? (and similar)
		* Would you like me to open that for you?
	* "EADDRINUSE"? Not sure I can help with that...
		* I can find an open port, but then what?
			* Monkey patch your code to use a different port? That would be awesome, but awful.
			* Suggest it (bit lame)
			* Suggest you use a module for finding an open port?
		* I don't think there's a way to find what program is using the port
	* Linkify URLs?


* Live reload everything
	* Chrome apps
	* `index.html`s
	* `npm start`s
	* **Except** when it already auto-reloads
		* (such as project-nexus does with nw-dev)
		* It could detect things like nw-dev,
		  but this might need to be something you configure
			(per project)


* Open devtools to debug a running node process


* I could also have a setting to explicitly detatch processes, or explicitly kill them, or use the OS default as it does now (windows leaves them open, linux kills 'em)


* I'd rather get as much functionality out the GUI before adding a general purpose command line


* Native elementary OS app
	* Headerbar
	* Make an nw.js elementary framework
		* https://github.com/elementary/web-styles
		* http://bazaar.launchpad.net/~elementary-design/egtk/trunk/view/head:/gtk-3.0/apps.css
			* Make [a module to compile gtk css to browser css](http://github.com/1j01/postcss-gtk)
	* Publish to [elementary apps](http://quassy.github.io/elementary-apps/) (and the App Center when it exists in the future)


* The properly capitalized name of a project is
  secretly stored most of the time in... README.md!
	* e.g. `# Project Nexus`


