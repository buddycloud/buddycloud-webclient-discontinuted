
class exports.ChannelEntry extends Backbone.View
    template: require 'templates/sidebar/entry'

    initialize: ->
        @selected = no
        @el = $("<div>").attr id:@cid
        @model.bind 'change:node:metadata', @render

    render: =>
        @update_attributes()
        old = @el; old.replaceWith @el = $(@template this).attr id:@cid
        @el.click =>
            app.views.home.setCurrentChannel @model.cid
        #@el.parent().remove(@el).prepend(@el) if @isPersonal()
        this

    isPersonal : (a, b) => # FIXME
        @channel?.metadata?.owner?.value is @model.get('jid') and (a ? true) or (b ? false)

    isSelected : (a, b) => # FIXME
        @selected and (a ? true) or (b ? false)

    update_attributes: ->
        if (channel = @model.nodes.get 'channel')
            @channel = channel.toJSON yes
        if (mood = @model.nodes.get 'mood')
            @mood = mood.toJSON yes
        if (geo = @model.nodes.get 'geo')
            @geo = geo.toJSON yes
