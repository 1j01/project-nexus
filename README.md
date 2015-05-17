
# Project Nexus

A hub for all your programming projects.

```
npm i project-nexus -g
project-nexus
```

<!--
Do you find yourself opening and closing lots of
* project folders
* git clients
* terminals (or shitty outdated command prompts)
* and/or code editors?

There are many repetitive steps involved in switching projects.

Does your workflow involve a lot of
switching to your terminal
(or shitty outdated command prompt)
and hitting
<kbd>Ctrl+C</kbd> +
<kbd>Up</kbd> +
<kbd>Enter</kbd>
to restart?

Have you ever habitually switched back and
accidentally reran some other command you had entered?

No more!
-->

You declare all your scripts in your package.json,
in a machine-readable format,
but all you directly gain from this
usually amounts to
not having to remember many commands
to start all your projects.
You just type `npm start`
– it's short and sweet –
but it doesn't have to end there.

Project Nexus gives you a visual interface
for launching all your projects.

If a project has a `package.json` file,
it'll give you a button to `npm start`/stop the project,
It opens a [terminal](https://github.com/chjj/term.js) to show process output.

If there's an `index.html`, it'll give you a button to open it.

If there's a `manifest.json`, it'll give you a button to launch a [chrome app](https://developer.chrome.com/apps/about_apps).
Clicking it again will restart the app.

I'm very open to extending it with different launchers.
I've made it partially modular,
although at this point the modules directly return React elements.
Before I separate the launchers into their own packages
(to level the playing field for new launchers if anyone wants to make one)
I want to abstract that a bit.

Plus, I want to have reusable dropdown functionality anyways
(for things like `npm`, `cake`, `make`, `rake` and such
where multiple scripts or tasks are commonly defined).


_Built with [nw.js](http://nwjs.io/)_


## Dev

- fork [project-nexus](https://github.com/1j01/project-nexus)

- `npm link`

- `project-nexus`

It'll live reload with [nw-dev](https://www.npmjs.com/package/nw-dev/)
