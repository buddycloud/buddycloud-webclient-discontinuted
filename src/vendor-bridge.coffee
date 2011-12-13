
require 'es5-shim'
require './vendor/ConsoleDummy'
require './vendor/document-redraw'

window.Strophe = require 'Strophe.js'
# plugins
require "./vendor/strophe.#{plugin}.js" for plugin in [
    "disco", "roster", "pubsub", "presence",
    "register", "datafoms", "buddycloud"
]

window.jQuery = window.$ = require 'jquery'
# plugins
# from vendor folder
require "./vendor/jquery.#{plugin}.js" for plugin in [
    "copycss", "mousewheel", "antiscroll", "autoresize",
    "autoresize+input", "animat-enhanced"
]
# from npm
require "jquery-#{plugin}" for plugin in [
    "inputevent", "textsaver", "autosuggestion"
]
require './vendor/transform.js'

# backbone
window._ = require 'underscore'
window.Backbone = require 'backbone'
require "./vendor/backbone-#{plugin}.js" for plugin in [
    "localstorage", "extensions"
]

window.Modernizr = require './vendor/modernizr'

require 'formatdate'
