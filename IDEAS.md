
### Project Nexus

# Ideas


* Open all your tools for you
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
			* Ungit is kinda ugly (and doesn't fit in very well)
				* I'm sure it could be themed, to some extent
			* [This](http://tonsky.me/blog/reinventing-git-interface/) is what I [really want](https://github.com/quassy/elementary-apps/issues/17)
	* ~~Folder browser~~ (**done**)
	* Configure whatever tools you want
	* Configure whether you want it to give you
		* an open/close project button, or
		* an open/focus project button (and what it would focus?)
	* and whether you want it to allow multiple projects open
	* Hopefully it can keep track of processes well enough
		* I'm thinking it would be bad if you navigate away from a project within a tool and close the project and the tool is killed even though it's no longer related to the project
			* I guess it would just have to warn you
				* And because of this, murderous behavior would be disabled by default
	* (If one workflow is obviously superior, maybe I can remove the setting)


* Auto detect common project superdirectories
	* such as created by Github for Windows
	* or by IDEs or other tools
	* and simple things like %USER%/Code or ~/code
		* "coding", "programming", etc.
		* Uppercase, lowercase, dashed (e.g. "coding-projects") or spaced


* Plugins
	* Only have columns for plugins that support at least one project
	* Launch multiple tasks (with dropdowns)
		* ~~`npm`~~ (**done**)
		* `cake`
		* `make`
		* `rake`
	* Let plugins add project openers for tools
		* Such as, when there's a solution (.sln) file,
		  it could open Visual Studio
			* In this case, it should override your Editor
	* An easy way to install plugins?


* Link to repository (defined in `package.json`)
	* A way to update `package.json` with repository info


* Visual package editor
	* Help text for known fields
	* Keeps your indentation and formatting (even though npm doesn't)
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
	* Linkify URLs


* Live reload everything
	* Chrome apps
	* `index.html` (start a webserver and inject a script)
	* `npm start`
	* Automatically run `npm prepublish` upon file changes
		* Also watch linked dependencies
			* Changing a file in the linked dependency might
			  trigger an auto-`prepublish`
			  and this should trigger an auto-`prepublish`
			  of the dependent project.
			* Unwatch unlinked dependencies
	* **Except** when it already auto-reloads
		* (such as project-nexus does with nw-dev)
		* It *could* try to detect things like nw-dev,
		  but this might need to be something you configure
			(per project)


* Open devtools to debug a running node process


* I could also have a setting to explicitly detatch processes, or explicitly kill them, or use the OS default as it does now (windows leaves them open, linux kills 'em)


* Handle having processes open when reloading (nw-dev)


* elementary OS app
	* Publish to [elementary apps](http://quassy.github.io/elementary-apps/) (and the App Center when it exists in the future)


* The properly capitalized name of a project is
  secretly stored in many cases in... README.md!
	* e.g. `# Project Nexus`
	* (with formatting that would need to be removed of course)
	* and other text file formats
	* and maybe `<html><title>`? maybe that's a bit presumptuous


* Better project organization (e.g. folders or groups or tags)


* Styles
	* Better focus styles for icon buttons (not an orange rectangular outline)
	* With dark (non-elementary) theme, the whole projects directory multi-input is non-dark (not that it *has* to be)
	* Could probably animate more transitions in ProjectDetails, possibly by adding an animation dummy element
	* With elementary mode, the project read error receives infobar styles and looks really stretched out.
	  Instead, it should use an actual infobar.
	  The bar should have a Browse button.
