{ SubscriptionStore } = require 'collections/subscription'
{ AffiliationStore } = require 'collections/affiliation'
{ UserMetadata } = require 'models/metadata/user'
{ Channels } = require 'collections/channel'
{ gravatar } = require 'helper'

class exports.User extends Backbone.Model

    initialize : ->
        @set id:@id = @get('jid')
        @channels = new Channels
        @metadata = new UserMetadata this, @id
        @avatar = gravatar @id, s:50, d:'retro'
        @affiliations  = new AffiliationStore  this
        @subscriptions = new SubscriptionStore this

