{ BaseView } = require '../base'
{ EventHandler } = require '../../util'
{ DiscoverGroupView } = require './group'
{ channels_to_collection } = require './util'

class exports.Startpage extends BaseView
    template: require '../../templates/discover/startpage'
    adapter: 'jquery'

    initialize: () ->
        @jobs = []
        @on('show', @show)
        @on('hide', @hide)
        super

        mostActive = new Backbone.Collection()
        @jobs.push [mostActive, 'get_most_active_nodes', null]
        popular = new Backbone.Collection()
        @jobs.push [popular, 'get_popular_nodes', null]
        @discover = new DiscoverGroupView
            lists:
                'mostActive':
                    name: "most active channels"
                    model: mostActive
                'popular':
                    name: "most popular channels"
                    model: popular

        @render()

    update: =>
        channels_to_collection.apply(this, job) for job in @jobs
        this

    show: ->
        $('body').addClass('startpage')

    hide: ->
        $('body').removeClass('startpage')

    render: (callback) ->
        super ->
            $('body').append(@$el)
            @discover.on('template:create', @trigger.bind(this, 'subview:discover'))
            @discover.render()
            callback?()

    destroy: =>
        return if @destroyed
        do @hide
        @discover.destroy()
        delete @discover
        delete @jobs
        super
