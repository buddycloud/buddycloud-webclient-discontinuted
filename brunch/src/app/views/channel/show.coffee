
# The channel shows channel content
class exports.ChannelView extends Backbone.View
  template: require 'templates/channel/show'

  initialize: =>
    @el = $("<div>").attr id:@cid
    @user = app.current_user

  render: =>
    @update_attributes()
    console.log "|||", this
    old = @el; old.replaceWith @el = $(@template this).attr id:@cid
    @info = @el.find('.channelDetails')
    console.warn "asasfasfasfasdfasdf", @info, @el, @el.find('.info.button')
    @el.find('.info.button').click => @info.toggleClass('hidden')
    this

  update_attributes: =>
    @channel = @model.toJSON()
    @channel.avatar = @model.avatar
    @user =
      notFollowingThisChannel: @channel.sink isnt app.current_user.get('jid')
      hasRightToPost: @channel.affiliation in ["owner", "publisher"] #permissions