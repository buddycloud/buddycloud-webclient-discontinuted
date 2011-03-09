/**
 * col2 BrowseView
 */

var BrowseView = Backbone.View.extend({
    el: '#col2',

    initialize: function(channel) {
        var that = this;
        this.channel = channel;
        this.render();

        _.bindAll(this, 'render', 'posted');
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

	    /*TODO: if (channelNode.canPublish())*/
		this.insertPostView();
        }
    },

    posted: function() {
	this.postView.remove();
	delete this.postView;

	this.insertPostView();
    },

    insertPostView: function() {
	if (this.postView) {
	    /* Already there */
	    return;
	}

        var channelNode = this.channel.getNode('channel');
        if (channelNode) {
	    var that = this;
            var postView = new BrowsePostView(channelNode);
            postView.bind('done', this.posted);
            this.insertView(postView);
	    this.postView = postView;
        }
    },

    insertView: function(view) {
	var before = this.postView &&
	    this.postView.el ||
	    $('#col2 h2');
	var published = view.getDate &&
	    view.getDate() ||
	    new Date();
	_.forEach(this.itemViews, function(itemView) {
	    var published1 = itemView &&
			  itemView.getDate &&
			  itemView.getDate();
	    if (published1 && published1 > published) {
		before = itemView.el;
	    }
	});

	/* add to view model & DOM */
        this.itemViews.push(view);
        before.after(view.el);
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
console.log('BrowseView remove')
        this.channel.unbind('change', this.render);
        this.channel.unbind('change:items', this.render);
        if (this.postView) {
            this.postView.unbind('done', this.posted);
	    this.postView.remove();
	}
        this.itemViews.forEach(function(itemView) {
            itemView.remove();
        });
    }
});

var BrowseItemView = Backbone.View.extend({
    initialize: function(item) {
        this.item = item;

        this.el = $(this.template);
        this.render();
    },

    render: function() {
        this.$('.entry-content p:nth-child(1)').text(this.item.getTextContent());

	var published = this.item.getPublished();
	if (published) {
	    var ago = $('<span></span>');
	    ago.attr('title', isoDateString(published));
	    this.$('.entry-content .meta').append(ago);
	    /* Activate plugin: */
	    ago.timeago();
	}
	/* TODO: add geoloc info */
    },

    /* for view ordering */
    getDate: function() {
	return this.item.getPublished();
    }
});

$(function() {
      BrowseItemView.prototype.template = $('#browse_entry_template').html();
});

/**
 * Triggers 'posted' so BrowseView can remove it on success.
 */
var BrowsePostView = Backbone.View.extend({
    events: {
        'click a.btn2': 'post'
    },

    initialize: function(node) {
        this.node = node;
        this.el = $(this.template);
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
                that.trigger('posted');
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
$(function() {
      BrowsePostView.prototype.template = $('#browse_post_template').html();
});
