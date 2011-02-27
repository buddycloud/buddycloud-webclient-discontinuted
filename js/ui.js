function xmlEscape(s) {
    return Strophe.xmlescape(s || '');
}

$(function() {
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

    var MyMessageView = Backbone.View.extend({
	el: '.my_message',
	template: _.template($('#my_message_template').html()),

	initialize: function() {
	    _.bindAll(this, 'render');
	    Channels.cl.bind('online', this.render);
	},

	render: function() {
	    $(this.el).html(this.template({ user: Channels.cl.jid, desc1: 'foo', desc2: 'bar' }));
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

    var AppView = Backbone.View.extend({
	el: '#wrap',

	initialize: function() {
	    this.channels = new Channels.Channels();
	    (new MyMessageView()).render();

	    this.channels.bind('add', function(channel) {
		console.log({channels: arguments});
		$('#col1').append(new MyChannelView(channel).render().el);
	    });
	},

	show: function() {
	    $(this.el).show();
	},
	hide: function() {
	    $(this.el).hide();
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
	},

	browseUser: function(user) {
	    if (this.mustLogin()) return;

	    console.log('browse ' + user);
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
