class CommonConnectingView extends Backbone.View
  initialize: ->
    @el = $("#auth-container")

    @template = _.template('''
      <div class="auth">
        <img src="/public/spinner-dark.gif?force" class="micro spinner">
        Connecting....
        <a href="#logout" class="signout">Cancel</a>
      </div>
    ''')

    @render()
    
  render: =>
    @el.html(@template())
    @delegateEvents()

@CommonConnectingView = CommonConnectingView

