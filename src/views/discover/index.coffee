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

        @views.local = new DiscoverGroupView
            name:"Local"
            id:"local"
            lists:
                'mostActive':"Most Active"
                'popular':"Popular"

        @views.global = new DiscoverGroupView
            name:"Global"
            id:"global"
            lists:
                'mostActive':"Most Active"
                'popular':"Popular"

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

