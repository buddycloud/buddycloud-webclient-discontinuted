var MyMessageView = Backbone.View.extend({
    el: '.my_message',

    initialize: function() {
	_.bindAll(this, 'render');
	Channels.cl.bind('online', this.render);
    },

    setChannel: function(channel) {
	if (this.channel) {
	    this.channel.unbind('change', this.render);
	    this.channel.unbind('change:items', this.render);
	}

	this.channel = channel;
	channel.bind('change', this.render);
	channel.bind('change:items', this.render);
	this.render();
    },

    render: function() {
	var channelNode = this.channel && this.channel.getNode('channel');
	var meta = channelNode && channelNode.get('meta');
	$(this.el).html(this.template({ user: Channels.cl.jid,
					desc1: meta && meta['pubsub#title'],
					desc2: meta && meta['pubsub#description']
				      }));
	}
});
$(function() {
    MyMessageView.prototype.template = _.template($('#my_message_template').html());
});
