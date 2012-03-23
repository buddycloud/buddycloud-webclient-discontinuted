{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverGroupView } = require './group'

# manages a list of groups
class exports.DiscoverView extends BaseView
    template: require '../../templates/discover/index'

    initialize: ->
        @views = {}
        @bind('hide', @hide)
        @button = $('.sidebar button.discover')
        @button.addClass('active')
        super

        ###
        @views.local = new DiscoverGroupView
            name:"Local"
            id:"local"
            lists:
                'mostActive':"Most Active"
                'popular':"Popular"
        ###

        my_jid = app.users.current.get('id')

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

    hide: =>
        @button.removeClass('active')

    render: (callback) ->
        super ->
            for _, view of @views
                do (view) => view.render =>
                    @trigger 'subview:group', view.el
            callback?.call(this)

channels_to_collection = (model, method, args...) ->
    {connector} = app.handler
    connector[method].call connector, args..., (err, jids) ->
        if jids
            for jid in jids
                model.add app.channels.get_or_create(id: jid)
