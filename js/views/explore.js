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
	if (active)
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
    initialize: function(options) {
	ExploreViewItem.prototype.initialize.call(this);

	this.channel = options.channel;

	_.bindAll(this, 'render');
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
