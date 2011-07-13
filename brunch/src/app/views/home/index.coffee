class exports.HomeView extends Backbone.View
  template : require('templates/home/index')

  initialize : ->
    app.current_user.bind "logged_in", @finish_view

  render : ->
    $('#content').html @template()

