class CommonLoginView extends Backbone.View
  initialize: ->
    @el = $("#auth-container")
  
    @template = _.template('''
      <form action="#signin" class="signin">
        <div class="f">
          <label for="jid">Login</label>
          <input name="jid" size="30" style="width: 180px" type="text" />
          <small style="display: none">
            <input checked="checked" name="remember_me" type="checkbox" value="1" /> Remember me
          </small>
        </div>
  
        <div class="f">
          <label for="password">Password</label>
          <input name="password" size="30" style="width: 120px" type="password" />
          <small>
            <a href="#forgot">Forgot your password?</a>
          </small>
        </div>
  
        <div class="f">
          <button type="submit">Sign in</button>
        </div>
      </form>
    ''')
  
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
    @el.html(@template( { users : @collection })).hide().fadeIn()
    @delegateEvents()
  
  flashMessage: (message) ->
    @el.find('.form-flash').remove()
    
    div = $("<div />").addClass('form-flash').text(message)
    div.appendTo @el.find('form')
    div.hide().slideDown().delay(3000).slideUp()

@CommonLoginView = CommonLoginView