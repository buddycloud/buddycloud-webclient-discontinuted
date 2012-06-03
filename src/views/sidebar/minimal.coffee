{ Searchbar } = require './search'
{ BaseView } = require '../base'

class exports.MinimalSidebar extends BaseView
    template: require '../../templates/sidebar/minimal'

    initialize: () ->
        super
        @hidden = yes
        @search = new Searchbar
            model:@parent.channels
            parent:this
        @hidden = yes

    render: (callback) ->
        super ->
            @search.render(callback)

    setCurrentEntry: -> # do nothing

    # sliding in animation
    moveIn: (t = 200) ->
        @$el?.animate(left:"0", t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @$el?.animate(left:"-#{@$el?.width?() ? 0}px", t)
        @hidden = yes

