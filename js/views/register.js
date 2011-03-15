var RegisterView = Backbone.View.extend({
    initialize: function(options) {
	this.serviceJid = options.serviceJid;
	this.cb = options.cb;
	this.el = $(this.template);
	this.message = new StatusMessageView({ content: this.el,
					       title: 'Register' });
	this.$('.jid').text(this.serviceJid);
	this.delegateEvents();
    },

    events: {
        'click input[type=submit]': 'register'
    },

    register: function() {
	var that = this;

        this.$('input').attr('disabled', 'disabled');
	this.$('.progress').html('<img src="/img/throbber.gif">');

	Channels.cl.register(this.serviceJid, function(err) {
	    if (err) {
		that.$('input').removeAttr('disabled');
		that.$('.progress').html('Error!');
	    } else {
		that.remove();
		if (that.cb)
		    that.cb();
	    }
	});
        return false;
    },

    remove: function() {
	Backbone.View.prototype.remove.apply(this, arguments);
	this.message.remove();
    }
});
$(function() {
    RegisterView.prototype.template = $('#register_template').html();
});
