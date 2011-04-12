var StatusMessageView = Backbone.View.extend({
    initialize: function(options) {
        this.el = $(this.template);
	$('#wrap').append(this.el);
	this.delegateEvents();
	this.$('h1').text(options.title);
	this.$('.content').append(options.content);
    },

    events: {
	'click .close': 'close'
    },

    close: function() {
	this.remove();
	return false;
    }
});

$(function() {
    /* template as string, TODO: spread pattern */
    StatusMessageView.prototype.template = $('#status_message_template').html();
});
