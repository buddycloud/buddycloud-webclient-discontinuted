/**
 * TODO: This may go in favour of weld-style
 */
function xmlEscape(s) {
    return Strophe.xmlescape(s || '');
}

/**
 * LoginView
 */
var LoginView = Backbone.View.extend({
    initialize: function() {
	this.el = $(this.template);
	this.message = new StatusMessageView({ content: this.el,
					       title: 'Login' });
	this.delegateEvents();
    },
    events: {
        'click input[type=submit]': 'login'
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
    },

    remove: function() {
	Backbone.View.prototype.remove.apply(this, arguments);
	this.message.remove();
    }
});
$(function() {
    LoginView.prototype.template = $('#login_template').html();
});
