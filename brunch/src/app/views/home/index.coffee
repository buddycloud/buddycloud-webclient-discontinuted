class exports.HomeView extends Backbone.View
  template : require('templates/home/index')

  initialize : ->
    app.current_user.bind "logged_in", @finish_view

  render : ->
    $('#main_content').html @template()
    
    @after_render()
    
  after_render : ->
    $('#home_content').delay(10).fadeIn()

  finish_view : ->
    #$('#home_content').slideUp("slow")