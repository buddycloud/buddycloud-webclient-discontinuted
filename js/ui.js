function xmlEscape(s) {
    return Strophe.xmlescape(s || '');
}

$(function() {
    var MyMessageView = Backbone.View.extend({
	el: '.my_message',
	template: _.template($('#my_message_template').html()),

	initialize: function() {
	    _.bindAll(this, 'render');
	    cl.on('online', this.render);
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
	},

	render: function() {
	    this.el.html(this.template({ user: this.channel.get('id') }));
	    return this;
	}
    });

    var appView = Backbone.View.extend({
	el: '#wrap',

	initialize: function() {
	    (new MyMessageView()).render();

	    window.channelEvents.on('newChannel', function(channel) {
		$('#col1').append(new MyChannelView(channel).render().el);
	    });
	}
    });

    new appView();
});
