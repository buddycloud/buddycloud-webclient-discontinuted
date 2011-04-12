/**
 * col3 ExploreView
 */

var ExploreView = Backbone.View.extend({
    el: '#col3',

    initialize: function() {
	this.views = [];
    },

    add: function(view, active) {
	this.collapseAll();

	this.views.unshift(view);
	this.$('#explore').prepend(view.el);
	view.el.addClass('active');

	view.render();
	view.delegateEvents();
    },

    collapseAll: function() {
	_.forEach(this.views, function(view) {
	    view.el.removeClass('active');
	});
    }
});

var ExploreViewItem = Backbone.View.extend({
    events: {
	'click h3': 'toggleActive'
    },

    initialize: function() {
	_.bindAll(this, 'toggleActive');
	this.el = $(this.template);
    },

    toggleActive: function() {
	this.el.toggleClass('active');
    }
});

var ExploreViewDetails = ExploreViewItem.extend({
    events: _.extend({
	'click .followers': 'showFollowers'
    }, ExploreViewItem.prototype.events),

    initialize: function(options) {
	ExploreViewItem.prototype.initialize.call(this);

	this.channel = options.channel;
	this.parent = options.parent;

	_.bindAll(this, 'render', 'showFollowers');
	this.channel.bind('change', this.render);
    },

    render: function() {
	this.hookChannelNode();

	var user = this.channel.get('id');
	this.$('h3').text('> ' + user + ' details');
	this.$('.user a').text(user);
	this.$('.user a').attr('href', '#browse/' + user);

	if (this.channelNode) {
	    var meta = this.channelNode.get('meta');
	    this.$('.desc1').text(meta && meta['pubsub#title']);
	    this.$('.desc2').text(meta && meta['pubsub#description']);

	    this.$('.followers').text(this.channelNode.get('subscribers').length);

	    if (meta && meta['pubsub#creation_date']) {
		var creationDate = new Date(meta['pubsub#creation_date']);
		this.$('.created').attr('title', creationDate && isoDateString(creationDate));
		if (!this.createdTimeagoActivated) {
		    this.$('.created').timeago();
		    /* Don't activate twice: */
		    this.createdTimeagoActivated = true;
		}
	    }
	}
    },

    hookChannelNode: function() {
	/* Got it already? */
	if (this.channelNode)
	    return;

	this.channelNode = this.channel.getNode('channel');
	/* Not available yet? */
	if (!this.channelNode)
	    return;

	this.channelNode.bind('change', this.render);
	this.channelNode.get('subscribers').bind('change', this.render);
    },

    showFollowers: function() {
	this.parent.add(new ExploreViewSubscribers({ channel: this.channel }));

	return false;
    },

    remove: function() {
	this.channel.unbind('change', this.render);

	if (this.channelNode) {
	    this.channelNode.unbind('change', this.render);
	    this.channelNode.get('subscribers').unbind('change', this.render);
	}
    }
});

$(function() {
      ExploreViewDetails.prototype.template = $('#explore_details_template').html();
});

var ExploreViewSubscribers = ExploreViewItem.extend({
    initialize: function(options) {
	ExploreViewItem.prototype.initialize.call(this);

	_.bindAll(this, 'addSubscriber');
	this.channel = options.channel;
	this.channel.bind('change', this.render);
	this.subscriberItems = [];
    },

    render: function() {
	this.hookChannelNode();

	this.$('h3').text('> ' + this.channel.get('id') + ' followers');
    },

    hookChannelNode: function() {
	/* Got it already? */
	if (this.channelNode)
	    return;

	this.channelNode = this.channel.getNode('channel');
	/* Not available yet? */
	if (!this.channelNode)
	    return;

	this.channelNode.bind('change', this.render);
	var subscribers = this.channelNode.get('subscribers');
	subscribers.forEach(this.addSubscriber);
	subscribers.bind('add', this.addSubscriber);
    },

    addSubscriber: function(subscriber) {
	var jid = subscriber.get('id');
	var channel = this.channel.get('channels').getChannel(jid);

	var item = new ExploreViewSubscribersItem({ channel: channel });
	this.subscriberItems.push(item);
	this.$('ul.the-followers').append(item.el);
    },

    remove: function() {
	Backbone.View.prototype.remove.apply(this, arguments);
	_.forEach(this.subscriberItems, function(item) {
	    item.remove();
	});
    }
});

$(function() {
      ExploreViewSubscribers.prototype.template = $('#explore_subscribers_template').html();
});

var ExploreViewSubscribersItem = ExploreViewItem.extend({
    initialize: function(options) {
	_.bindAll(this, 'render');
	this.el = $(this.template);

	this.channel = options.channel;
	this.channel.bind('change', this.render);
	this.render();
    },

    render: function() {
	var jid = this.channel.get('id');
	this.$('.user').text(jid);
	this.$('a').attr('href', '#browse/' + jid);
	this.$('img').attr('src', this.channel.getAvatarURL());
    },

    remove: function() {
	this.channel.unbind('change', this.render);
    }
});

$(function() {
      ExploreViewSubscribersItem.prototype.template = $('#explore_subscriber_template').html();
});
