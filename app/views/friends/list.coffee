class FriendsListView extends Backbone.View
  initialize: ->
    @el = $("#friends-list")

    @template = _.template('''
      <% users.each(function(user){ %>
        <li>
          <img class="micro avatar" src="<%= user.getAvatar() %>" />
          <b><a href="#users/<%= user.get('jid') %>"><%= user.getName() %></a></b>
          <% if(user.getMood()){ %>
            - <span class="mood"><%= user.getMood() %></span>
          <% } %>
        </li>
      <% }); %>
    ''')

    @collection.bind 'all', @render

    @render()
    
  render: =>
    @el.html(@template( { users : @collection }))
    @delegateEvents()

@FriendsListView = FriendsListView