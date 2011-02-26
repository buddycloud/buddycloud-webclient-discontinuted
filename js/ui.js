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

	initialize: function(model) {
	    this.model = model;
	    this.el = $('<div></div>');
	},

	render: function() {
	    var vars = { user: this.model.get('id'),
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
	    return "foo in " + nodeTail;
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
