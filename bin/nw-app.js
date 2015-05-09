#!/usr/bin/env node

var resolve = require("path").resolve;
var spawn = require("child_process").spawn;
var nw = require("nw").findpath();

var app_dir = resolve(__dirname, "..", "app");

spawn(nw, [app_dir], {stdio: "inherit"});
