class CommonConnectingView extends Backbone.View
  initialize: ->
    @el = $("#auth-container")

    @template = _.template('''
      <div class="auth">
        <img src="/public/icons/net_comp.png" class="micro avatar">
        Connecting....
        <a href="#logout" class="signout">Cancel</a>
      </div>
    ''')

    @render()
    
  render: =>
    @el.html(@template( { user : app.currentUser } ))
    @delegateEvents()

@CommonConnectingView = CommonConnectingView

