
class exports.IndexView extends Backbone.View
    template: require 'templates/home/index'

    initialize: ->
        @bind 'show', @render
        @bind 'hide', @remove

    render: ->
        $('#content').html @el = $(@template())

