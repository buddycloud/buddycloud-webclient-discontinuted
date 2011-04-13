class ChannelsListView extends Backbone.View
  initialize: ->
    @el = $("#channels-list")

    @template = _.template('''
      <% channels.each(function(channel){ %>
        <li>
          <b><a href="#channels/<%= channel.getName() %>"><%= channel.getName() %></a></b>
          <span data-id="<%= channel.id %>" class="remove inline-action" title="Remove this channel from my favourites"><img src="/public/icons/trash.png" /></span>
        </li>
      <% }); %>
    ''')

    @collection.bind 'add', @render
    @collection.bind 'change', @render
    @collection.bind 'remove', @render
    @collection.bind 'refresh', @render

    @render()
    
  events: 
    'click .remove' : "onRemove"
    
  render: =>
    @el.html(@template( { channels : @collection }))
    @delegateEvents()
    
  onRemove: (e) =>
    id = $(e.currentTarget).attr('data-id')
    @collection.get(id).destroy()

@ChannelsListView = ChannelsListView