## Polyfills
require './vendor/ConsoleDummy'
require './vendor/document-redraw'

## Strophe.js
require 'Strophe.js'
# plugins
require "./vendor/strophe.disco.js"
require "./vendor/strophe.roster.js"
require "./vendor/strophe.pubsub.js"
require "./vendor/strophe.presence.js"
require "./vendor/strophe.register.js"
require "./vendor/strophe.dataforms.js"
require "./vendor/strophe.buddycloud.js"
require "./vendor/strophe.oembed.js"

## jQuery
window.jQuery = window.$ = require 'jquery'
# plugins
# from vendor folder
require "./vendor/jquery.copycss.js"
require "./vendor/jquery.mousewheel.js"
require "./vendor/jquery.antiscroll.js"
require "./vendor/jquery.autoresize.js"
require "./vendor/jquery.autoresize+input.js"
require "./vendor/jquery.animate-enhanced.js"
# from npm
require "jquery-inputevent"
require "jquery-textsaver"
require "jquery-autosuggestion"

require './vendor/transform.js'

## Backbone.js
window._ = require 'underscore'
window.Backbone = require 'backbone'
# plugins
require "./vendor/backbone-localstorage.js"
require "./vendor/backbone-extensions.js"

## helpers

require './vendor/modernizr'
