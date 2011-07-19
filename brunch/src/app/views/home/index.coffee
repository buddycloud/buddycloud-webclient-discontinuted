class exports.IndexView extends Backbone.View
  template: require 'templates/home/index'

  initialize: =>

  render: =>
    $('#content').html @el = $(@template())

  show: =>
    @render()

