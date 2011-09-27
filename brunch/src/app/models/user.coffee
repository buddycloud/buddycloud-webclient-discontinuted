{ UserMetadata } = require 'models/metadata/user'
{ UserChannels } = require 'collections/channel'
{ gravatar } = require 'helper'

class exports.User extends Backbone.Model

    initialize : ->
        # id and jid are the same
        @set id:get 'jid'
        # subscribed channels
        @channels = new UserChannels parent:this
        @metadata = new UserMetadata parent:this
