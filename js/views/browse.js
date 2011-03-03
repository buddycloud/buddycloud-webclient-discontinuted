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
    initialize: function(item) {
        this.item = item;

        this.el = $(this.template());
        this.render();
    },

    render: function() {
        this.$('.entry-content p').text(this.item.getTextContent());
    }
});

$(function() {
      BrowseItemView.prototype.template = _.template($('#browse_entry_template').html());
});

var BrowsePostView = Backbone.View.extend({
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
$(function() {
      BrowsePostView.prototype.template = _.template($('#browse_post_template').html());
});
