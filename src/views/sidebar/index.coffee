{ ChannelOverView } = require './more'
{ ChannelEntry } = require './entry'
{ Searchbar } = require './search'
{ BaseView } = require '../base'

# The sidebar shows all channels the user is:
# * subscribed to
# * viewed recently
class exports.Sidebar extends BaseView
    template: require '../../templates/sidebar/index'

    initialize: () ->
        super
        @hidden = yes
        @search = new Searchbar
            channels:@parent.channels
            parent:this
#         @search.bind 'filter', @render

    render: (callback) ->
        super ->
            # goes straight to MainView::template
            console.log "sidebar", @el
            @parent.trigger 'subview:sidebar', @el
            @search.render(callback)

    setCurrentEntry: (channel) => # FIXME

    # sliding in animation
    moveIn: (t = 200) ->
        @el.animate?(left:"0", t)
#         @overview.show(t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @el.animate?(left:"-#{@el.width?()}px", t)
#         @overview.hide(t)
        @hidden = yes
