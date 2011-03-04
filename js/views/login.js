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

	_.bindAll(this, 'loginFailed');
	Channels.cl.bind('error', this.loginFailed);
    },
    events: {
        'click input[type=submit]': 'login'
    },
    login: function() {
        this.$('input').attr('disabled', 'disabled');
	this.$('.progress').html('<img src="/img/throbber.gif">');

        Channels.cl.connect(this.$('#login_jid').val(), this.$('#login_password').val());
        return false;
    },

    loginFailed: function(err) {
	this.$('.progress').html('');
	this.$('.progress').text(err && err.message);
        this.$('input').removeAttr('disabled');

	this.$('#login_password')[0].focus();
    },

    remove: function() {
	Channels.cl.unbind('error', this.loginFailed);
	Backbone.View.prototype.remove.apply(this, arguments);
	this.message.remove();
    }
});
$(function() {
    LoginView.prototype.template = $('#login_template').html();
});
