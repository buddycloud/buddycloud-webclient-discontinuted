class exports.UserMenu extends Backbone.View
  template : require 'templates/shared/user_menu'
  
  initialize : ->
    app.current_user.bind "logged_in", @render
    app.current_user.bind "logged_out", @finish_view
    @el = $('#user_menu')
    $('#login_form').submit ->
      app.current_user.log_in()
      $(this).hide()
      $(this).after '<img class="loading" src="/public/spinner2.gif" />'
      return false

  show_login : ->
    $('#login_form').fadeIn()

  render : =>
    @el.hide()
    @el.html @template app.current_user.toJSON()
    @el.fadeIn("slow")
    
  finish_view : =>
    @el.fadeOut()