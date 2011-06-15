class exports.UserMenu extends Backbone.View
  template : require 'templates/shared/user_menu'
  
  initialize : ->
    app.current_user.bind "logged_in", @render
    app.current_user.bind "logged_out", @finish_view
    @el = $('#user_menu')
    $('#login_form').submit ->
      # the form sumbit will alwasy trigger a new connection
      BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind'
      @c = new Strophe.Connection(BOSH_SERVICE)
      console.log @c
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