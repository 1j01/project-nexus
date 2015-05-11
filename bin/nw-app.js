#!/usr/bin/env node

var resolve = require("path").resolve;
var spawn = require("child_process").spawn;
var nw = require("nw").findpath();

var app_dir = resolve(__dirname, "..");

spawn(nw, [app_dir]);
