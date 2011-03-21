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
	this.$('h3').text('> ' + this.channel.get('id') + ' details');
    }
});

$(function() {
      ExploreViewDetails.prototype.template = $('#explore_details_template').html();
});
