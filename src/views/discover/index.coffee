{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverGroupView } = require './group'

# manages a list of groups
class exports.DiscoverView extends BaseView
    template: require '../../templates/discover/index'
    adapter: 'jquery'
    overlay: yes

    initialize: ->
        @views = {}
        @bind('show', @show)
        @bind('hide', @hide)
        @button = $('.sidebar button.discover')
        super

        my_jid = app.users.current.get('id')

        mostActive = new Backbone.Collection()
        channels_to_collection mostActive, 'get_most_active_nodes', null
        popular = new Backbone.Collection()
        channels_to_collection popular, 'get_popular_nodes', null
        @views.local = new DiscoverGroupView
            name:"Local"
            id:"local"
            lists:
                'mostActive':
                    name: "Most Active"
                    model: mostActive
                'popular':
                    name: "Popular"
                    model: popular

        recommended = new Backbone.Collection()
        channels_to_collection recommended, 'recommend_channels', my_jid, 10
        @views.global = new DiscoverGroupView
            name:"Global"
            id:"global"
            lists:
                'recommended':
                    name: "Recommended to you"
                    model: recommended
                #"Most Active":
                #"Popular":

#         @views.location = new DiscoverGroupView # FIXME
#             name:"Location"
#             id:"location"
#             lists:
#                 'nearby':"Nearby"


    show: =>
        @button.addClass('active')

    hide: =>
        @button.removeClass('active')

    render: (callback) ->
        super ->
            for _, view of @views
                view.on('template:create', @trigger.bind(this, 'subview:group'))
                view.render()
            $('body').append(@$el)
            callback?.call(this)

    destroy: =>
        return if @destroyed
        view?.destroy() for view in @views
        delete @button
        delete @views
        super

channels_to_collection = (model, method, args...) ->
    {connector} = app.handler
    connector[method].call connector, args..., (err, jids) ->
        if jids
            for jid in jids
                # Some queries return nodes not jids:
                if (m = jid.match(/\/user\/([^\/]+)/))
                    jid = m[1]
                unless model.get(jid)?
                    model.add app.channels.get_or_create(id: jid)
