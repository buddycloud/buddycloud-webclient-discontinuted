function xmlEscape(s) {
    return Strophe.xmlescape(s || '');
}

$(function() {
    /**
     * LoginView
     */
    var LoginView = Backbone.View.extend({
	el: '#login',

	initialize: function() {
	},

	show: function() {
	    $(this.el).show();
	    this.enableAll();
	},
	hide: function() {
	    $(this.el).hide();
	},

	events: {
	    'submit form': 'login'
	},

	login: function() {
	    this.disableAll();
	    Channels.cl.connect(this.$('#login_jid').val(), this.$('#login_password').val());

	    return false;
	},

	disableAll: function() {
	    this.$('input').attr('disabled', 'disabled');
	},
	enableAll: function() {
	    this.$('input').removeAttr('disabled');
	}
    });

    /**
     * Get text content of the last entry of a node.
     */
    function peek(channel, nodeTail) {
	var node = channel.getNode(nodeTail);
	var item = node && node.getLastItem();
	return item && item.getTextContent();
    }

    var MyMessageView = Backbone.View.extend({
	el: '.my_message',
	template: _.template($('#my_message_template').html()),

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

    /**
     * col1 MyChannelView
     *
     * TODO:
     * * indicate loading state
     * * filter by actual subscribed channels
     */

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
			 channel: peek(this.channel, 'channel'),
			 geoPrevious: peek(this.channel, 'geo/previous'),
			 geoCurrent: peek(this.channel, 'geo/current'),
			 geoFuture: peek(this.channel, 'geo/future')
		       };
	    this.el.html(this.template(vars));
	    return this;
	}
    });

    /**
     * col2 BrowseView
     */

    var BrowseView = Backbone.View.extend({
	el: '#col2',

	initialize: function(channel) {
	    var that = this;
	    this.channel = channel;
	    this.render();

	    _.bindAll(this, 'render', 'insertPostView');
	    channel.bind('change', this.render);
	    channel.bind('change:items', this.render);

	    this.itemViews = [];
	    var channelNode = channel.getNode('channel');
	    if (channelNode) {
		var items = channelNode.get('items');
		/* Populate with existing items */
		items.forEach(function(item) {
		    that.insertView(new BrowseItemView(item));
		});
		/* Hook future updates */
		items.bind('add', function(item) {
		    that.insertView(new BrowseItemView(item));
		});

		this.insertPostView();
	    }
	},

	insertPostView: function() {
	    var channelNode = this.channel.getNode('channel');
	    if (channelNode) {
		this.postView = new BrowsePostView(channelNode);
		this.postView.bind('remove', this.insertPostView);
		this.insertView(this.postView);
	    }
	},

	insertView: function(view) {
	    this.itemViews.push(view);
	    $('#col2 h2').after(view.el);
	    /* Views may not have an `el' field before their
	     * `initialize()' member is called. We need to trigger
	     * binding events again: */
	    view.delegateEvents();
	},

	render: function() {
	    this.$('.col-title').text('> ' + this.channel.get('id'));
	    $('#c1').text(peek(this.channel, 'geo/future') || '');
	    $('#c2').text(peek(this.channel, 'geo/current') || '');
	    $('#c3').text(peek(this.channel, 'geo/previous') || '');
	},

	/**
	 * Backbone's remove() just removes this.el, which we don't
	 * want. Therefore we don't call the superclass.
	 */
	remove: function() {
	    this.channel.unbind('change', this.render);
	    this.channel.unbind('change:items', this.render);
	    if (this.postView)
		this.postView.unbind('remove', this.insertPostView);
	    this.itemViews.forEach(function(itemView) {
		itemView.remove();
	    });
	}
    });

    var BrowseItemView = Backbone.View.extend({
	template: _.template($('#browse_entry_template').html()),

	initialize: function(item) {
	    this.item = item;

	    this.el = $(this.template());
	    this.render();
	},

	render: function() {
	    this.$('.entry-content p').text(this.item.getTextContent());
	}
    });

    var BrowsePostView = Backbone.View.extend({
	template: _.template($('#browse_post_template').html()),

	events: {
	    'click a.btn2': 'post'
	},

	initialize: function(node) {
	    this.node = node;
	    this.el = $(this.template());
	    this.$('textarea')[0].focus();
	},

	post: function() {
	    var that = this;
	    var textarea = this.$('textarea');
	    textarea.attr('disabled', 'disabled');
	    this.$('a.btn2').hide();
	    this.node.post(textarea.val(), function(err) {
		if (err) {
		    textarea.removeAttr('disabled');
		    this.$('a.btn2').show();
		} else {
		    that.remove();
		    /* TODO: not subscribed? manual refresh */
		}
	    });

	    return false;
	},

	remove: function() {
	    this.trigger('remove');
	    Backbone.View.prototype.remove.apply(this, arguments);
	}
    });

    /**
     * Main AppView
     */

    var AppView = Backbone.View.extend({
	el: '#wrap',

	initialize: function() {
	    this.channels = new Channels.Channels();
	    this.myMessage = new MyMessageView();
	    this.myMessage.render();

	    var that = this;
	    this.channels.bind('add', function(channel) {
		console.log({channels: arguments});

		/* update header if own channel */
		if (channel.get('id') === Channels.cl.jid)
		    that.myMessage.setChannel(channel);

		/* add to .col1 */
		$('#col1').append(new MyChannelView(channel).render().el);
	    });
	},

	show: function() {
	    $(this.el).show();
	},
	hide: function() {
	    $(this.el).hide();
	},

	browseUser: function(user) {
	    if (this.browseView) {
		this.browseView.remove();
		delete this.browseView;
	    }

	    var channel = this.channels.getChannel(user);
	    if (channel)
		this.browseView = new BrowseView(channel);
	}
    });

    var AppController = Backbone.Controller.extend({
	initialize: function() {
	    this.login = new LoginView();
	    this.view = new AppView();
	},

	routes: {
	    'login': 'login',
	    '': 'index',
	    'browse/:user': 'browseUser'
	},

	login: function() {
	    if (this.mustLogin()) {
		this.view.hide();
		this.login.show();

		var that = this;
		var success = function() {
		    Channels.cl.unbind('online', success);
		    console.log({'login success':Channels.cl});
		    window.location = '#';
		};
		Channels.cl.bind('online', success);
	    } else {
		window.location = '#';
	    }
	},

	index: function() {
	    if (this.mustLogin()) return;

	    this.login.hide();
	    this.view.show();

	    /* Forward to own channel */
	    this.location = '#browse/' + Channels.cl.jid;
	},

	browseUser: function(user) {
	    if (this.mustLogin()) return;

	    this.view.browseUser(user);
	},

	/**
	 * Helper
	 */
	mustLogin: function() {
	    if (!Channels.cl.conn.authenticated) {
		window.location = '#login';
		return true;
	    } else {
		return false;
	    }
	}
    });
    new AppController();
    Backbone.history.start();
});
