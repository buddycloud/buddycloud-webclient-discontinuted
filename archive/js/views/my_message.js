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
	this.$('.my_message_user').text(Channels.cl.jid);
	this.$('.my_message_desc1').text(meta && meta['pubsub#title']);
	this.$('.my_message_desc2').text(meta && meta['pubsub#description']);
    }
});
