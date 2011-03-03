/**
 * Get text content of the last entry of a node.
 */
function peek(channel, nodeTail) {
    var node = channel.getNode(nodeTail);
    var item = node && node.getLastItem();
    return item && item.getTextContent();
}


/**
 * col1 MyChannelView
 *
 * TODO:
 * * indicate loading state
 * * filter by actual subscribed channels
 */
 var MyChannelView = Backbone.View.extend({
    initialize: function(channel) {
        this.channel = channel;
        this.el = $('<div></div>');
         _.bindAll(this, 'render');
        channel.bind('change', this.render);
        channel.bind('change:items', this.render);
        channel.bind('all', function(ev) {
            console.log('channel ' + channel.get('id') + ' - ' + ev);
        });
    },

    render: function() {
        var vars = { user: this.channel.get('id'),
                     channel: peek(this.channel, 'channel'),
                     geoPrevious: peek(this.channel, 'geo/previous'),
                     geoCurrent: peek(this.channel, 'geo/current'),
                     geoFuture: peek(this.channel, 'geo/future')
                   };
        this.el.html(this.template(vars));
        return this;
    }
});

$(function() {
    MyChannelView.prototype.template = _.template($('#my_channel_template').html());
});
