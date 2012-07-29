{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverGroupView } = require './group'
{ channels_to_collection } = require './util'

# manages a list of groups
class exports.DiscoverView extends BaseView
    template: require '../../templates/discover/index'
    adapter: 'jquery'
    overlay: yes

    initialize: ->
        @views = {}
        @jobs = []
        @bind('show', @show)
        @bind('hide', @hide)
        @button = $('.sidebar button.discover')
        super

        my_jid = app.users.current.get('id')

        mostActive = new Backbone.Collection()
        @jobs.push [mostActive, 'get_most_active_nodes', null]
        popular = new Backbone.Collection()
        @jobs.push [popular, 'get_popular_nodes', null]
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
        @jobs.push [recommended, 'recommend_channels', my_jid, 10]
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

        @render()

    update: =>
        channels_to_collection.apply(this, job) for job in @jobs
        this

    show: =>
        @button.addClass('active')

    hide: =>
        @button.removeClass('active')

    render: (callback) ->
        super ->
            $('body').append(@$el)
            for _, view of @views
                view.on('template:create', @trigger.bind(this, 'subview:group'))
                view.render()
            callback?.call(this)

    destroy: =>
        return if @destroyed
        view?.destroy() for view in @views
        delete @button
        delete @views
        delete @jobs
        super

