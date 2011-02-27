function xmlEscape(s) {
    return Strophe.xmlescape(s || '');
}

$(function() {
    var MyMessageView = Backbone.View.extend({
	el: '.my_message',
	template: _.template($('#my_message_template').html()),

	initialize: function() {
	    _.bindAll(this, 'render');
	    cl.bind('online', this.render);
	},

	render: function() {
	    $(this.el).html(this.template({ user: cl.jid, desc1: 'foo', desc2: 'bar' }));
	}
    });

    var MyChannelView = Backbone.View.extend({
	template: _.template($('#my_channel_template').html()),

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
			 channel: this.peek('channel'),
			 geoPrevious: this.peek('geo/previous'),
			 geoCurrent: this.peek('geo/current'),
			 geoFuture: this.peek('geo/future')
		       };
	    this.el.html(this.template(vars));
	    return this;
	},

	/**
	 * Get content of the last entry of a node.
	 */
	peek: function(nodeTail) {
	    var node = this.channel.getNode(nodeTail);
	    var item = node && node.getLastItem();
	    var contentEls = item && $(item.get('elements')).find('content');
	    console.log({node:node,item:item,contentEls:contentEls})
	    return contentEls && $(contentEls[0]).text();
	}
    });

    var appView = Backbone.View.extend({
	el: '#wrap',

	initialize: function() {
	    this.channels = new window.Channels();
	    (new MyMessageView()).render();

	    this.channels.bind('add', function(channel) {
		console.log({channels: arguments});
		$('#col1').append(new MyChannelView(channel).render().el);
	    });
	}
    });

    new appView();
});
