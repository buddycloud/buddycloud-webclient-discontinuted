class exports.LoginView extends Backbone.View
  template : require("templates/home/login")
  initialize : ->
    app.current_user.bind "logged_in", @finish_view
    
  render : ->
    @el.html do @template
    console.log do @template
    do @after_render
    @el
    
  after_render : ->
    console.log $('#home_login_submit').length
   

  finish_view : =>
    @$('.loading').remove()
    @$('#home_login_submit').show()
    @el.fadeOut "slow", -> $(this).remove()