class AuthLoginView extends Backbone.View
  initialize: ->
    @el = $("#content")

    $("#spinner").remove()

    @template = _.template('''
    
      <div class="grid_12">
        <h1>
          A social network that is friends with the other social networks
        </h1>
      </div>

      <div class="grid_6">
        <p>
          This is a branch of <a href="https://github.com/diaspora/diaspora">Diaspora</a> that supports the <a href="http://activitystrea.ms/">Activity Streams</a> standard.
          This is the primary diaspora*x server for public use, or you can <a href="http://github.com/bnolan/diaspora-x2">run your own</a>.
        </p>

        <h2><span>Sign Up</span></h2>

        <div>
          <p>
            <small>
              Its free, forever.
            </small>
          </p>

          <form action="#signup" class="signup">

            <div class="f">
              <label for="jid">Login</label>
              <input name="jid" size="30" style="width: 120px" type="text" /> @ diaspora-x.com
            </div>

            <div class="f">
              <label for="email">Email</label>
              <input name="email" size="30" type="text" value="" />
            </div>

            <div class="f">
              <label for="password">Password</label>
              <input name="password" size="30" style="width: 80px" type="password" />
            </div>

            <div class="f">
              <label for="password_confirmation">Confirm Password</label>
              <input name="password_confirmation" size="30" style="width: 80px" type="password" />
            </div>

            <div class="f"><input id="user_submit" name="commit" type="submit" value="Sign up" /></div>
          </form>
        </div>
        
        
      </div>
    ''')

    @render()
    
  events: {
    'submit form.signup' : 'signup'
  }
  
  signup: (e) =>
    jid = @el.find(".signin input[name='jid']").val()
    password = @el.find(".signin input[name='password']").val()

    console.log [jid, password]
    
    if jid.match(/@/) && password.length > 0
      localStorage['jid'] = jid
      localStorage['password'] = password
      app.connect()
    else
      alert "Invalid login / password..."
    
    e.preventDefault()
    
  render: =>
    $('ul.tabs li').hide()
    
    @el.html(@template( { users : @collection })).hide().fadeIn()
    @delegateEvents()
    
    new CommonLoginView()

@AuthLoginView = AuthLoginView