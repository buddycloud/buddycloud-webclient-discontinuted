class ChannelsIndexView extends Backbone.View
  initialize: ->
    new CommonPageView
    @el = $("#main")

    @template = _.template('''

      <h1>Subscribed Channels</h1>

      <ul class="big-channel-list">
        <% this.collection.each(function(channel){ %>
          <li>
            <a href="#channels/<%= channel.getName() %>">
              <%= channel.getName().capitalize() %>
            </a>
            <p class="description">
              <%= channel.escape('description') %>
            </p>
            <span data-id="<%= channel.id %>" class="remove inline-action" title="Remove this channel from my favourites"><img src="/public/icons/trash.png" /></span>
          </li>
        <% }); %>
      </ul>
      
      <h3>Discover more channels</h3>
      
      <p>
        Channels are places to discuss a topic with anyone who is interested. Anyone can join a channel, 
        and you can see everyones comments.
      </p>
    ''')

    @collection.bind 'all', @render
    
    @render()
  
  events:
    'click .unsubscribe' : 'unsubscribe'
    'click .subscribe' : 'subscribe'
    'click .remove' : "onRemove"
  
  onRemove: (e) =>
    id = $(e.currentTarget).attr('data-id')
    @collection.get(id).destroy()

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
    $("#main-tabs li:nth-child(2)").addClass('active')

@ChannelsIndexView = ChannelsIndexView