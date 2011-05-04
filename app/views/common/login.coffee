class CommonLoginView extends Backbone.View
  initialize: ->
    @el = $("#auth-container")
  
    @render()
    
  events: {
    'submit form.signin' : 'signin'
  }
  
  signin: (e) =>
    e.preventDefault()
  
    jid = @el.find("input[name='jid']").val()
    password = @el.find("input[name='password']").val()
    
    if jid.match(/@/) && password.length > 0
      app.connect(jid, password, true)
    else    
      @flashMessage "Invalid login / password..."
    
  render: =>
    @el.html($templates.commonLogin( { users : @collection })).hide().fadeIn()
    @delegateEvents()
  
  flashMessage: (message) ->
    @el.find('.form-flash').remove()
    
    div = $("<div />").addClass('form-flash').text(message)
    div.appendTo @el.find('form')
    div.hide().slideDown().delay(3000).slideUp()

@CommonLoginView = CommonLoginView