{ Searchbar } = require './search'
{ BaseView } = require '../base'

class exports.MinimalSidebar extends BaseView
    template: require '../../templates/sidebar/minimal'

    events:
        'click button.discover': 'clickDiscover'

    initialize: () ->
        super
        @hidden = yes
        @search = new Searchbar
            model:@parent.channels
            parent:this

    render: (callback) ->
        super ->
            @search.render(callback)

    setCurrentEntry: -> # do nothing

    clickDiscover: ->
        app.router.navigate "discover", true

    # sliding in animation
    moveIn: (t = 200) ->
        @$el?.animate(left:"0", t)
        @hidden = no

    # sliding out animation
    moveOut: (t = 200) ->
        @$el?.animate(left:"-#{@$el?.width?() ? 0}px", t)
        @hidden = yes

    destroy: =>
        return if @destroyed
        @search.destroy()
        delete @search
        super
