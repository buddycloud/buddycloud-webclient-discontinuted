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
