
# Project Nexus

A hub for all your programming projects.


Do you find yourself opening and closing lots of
* project folders
* git clients
* terminals / shitty command windows
* and code editors?

Maybe you don't need to *close* all of these things,
but there are still many repetitive steps involved in switching projects.

Do you find yourself switching to your terminal
or shitty outdated command window
and hitting
<kbd>Ctrl+C</kbd> +
<kbd>˄</kbd> +
<kbd>Enter</kbd>
to restart?

No more!
Well, it's a work in projects.
I mean, progress.
Currently it doesn't really help you switch projects.

So far,
there's a settings modal where you choose a projects directory,
and then it finds all the sudirectories and assumes these are your projects.

If a project has a `package.json` file,
the listing is given a button to `npm start` the project,
and to `npm stop` it if there happens to be a `stop` script,
otherwise kill the process.

If there's no `package.json`, it'll give you a button to open `index.html`.

If there's neither, ya get naught.

I'm open to extending it with different openers.
(I'll probably try to modularize this!)
After all, even I have a python project or two.
Or one, but you get the idea.


_Built with [nw.js](http://nwjs.io/)_


## Dev

1. Have `npm` (from [node.js](http://nodejs.org/) or [io.js](http://iojs.org/))

2. Run `npm install` in the project directory (or `npm i`)

3. Run `npm start` in the project directory

