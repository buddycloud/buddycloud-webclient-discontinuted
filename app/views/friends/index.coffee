class FriendsIndexView extends Backbone.View
  initialize: ->
    # new CommonPageView
    # @el = $("#main")
    # 
    @template = _.template('''

      <h1>Friends</h1>

      <ul class="big-friends-list">
        <% this.collection.each(function(friend){ %>
          <li>
            <a href="#channels/<%= friend.getFullName() %>">
              <%= friend.getName().capitalize() %>
            </a>
            <p class="mood">
              <%= friend.getMood() %>
            </p>
          </li>
        <% }); %>
      </ul>
      
      <h3>Add your friends!</h3>
      
      <p>
        ...
      </p>
    ''')

    @collection.bind 'all', @render
    
    @render()
  
  events: {
    'click .unsubscribe' : 'unsubscribe'
    'click .subscribe' : 'subscribe'
  }
  
  subscribe: (e) =>
    # e.preventDefault()
    # @model.subscribe()
    
  unsubscribe: (e) =>
    # e.preventDefault()
    # @model.unsubscribe()

  render: =>
    @el.html(@template(this))
    @delegateEvents()

    # Focus the second tab
    $("#main-tabs li").removeClass('active')
    $("#main-tabs li:nth-child(3)").addClass('active')

@FriendsIndexView = FriendsIndexView