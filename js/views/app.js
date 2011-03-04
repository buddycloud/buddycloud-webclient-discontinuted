/**
 * Main AppView
 */

var AppView = Backbone.View.extend({
    el: '#wrap',

    initialize: function() {
        this.channels = new Channels.Channels();
        this.myMessage = new MyMessageView();
        this.myMessage.render();

        var that = this;
        this.channels.bind('add', function(channel) {
            console.log({channels: arguments});

             /* update header if own channel */
            if (channel.get('id') === Channels.cl.jid)
                that.myMessage.setChannel(channel);

            /* add to .col1 */
            $('#col1').append(new MyChannelView(channel).render().el);
        });
    },

    browseUser: function(user) {
        if (this.browseView) {
            this.browseView.remove();
            delete this.browseView;
        }

        var channel = this.channels.getChannel(user);
        if (channel)
            this.browseView = new BrowseView(channel);
    }
});

var AppController = Backbone.Controller.extend({
    initialize: function() {
        this.view = new AppView();
    },

    routes: {
        'login': 'login',
        '': 'index',
        'browse/:user': 'browseUser'
    },

    login: function() {
	console.log('login');
        if (this.mustLogin() && !this.loginView) {
	    this.loginView = new LoginView();

            var that = this;
            var success = function() {
		that.loginView.remove();
		delete that.loginView;

                Channels.cl.unbind('online', success);
                window.location = '#';
            };
            Channels.cl.bind('online', success);
        } else if (!this.loginView) {
            window.location = '#';
        }
    },

    index: function() {
	console.log('index');
        if (this.mustLogin()) return;

        /* Forward to own channel */
        this.location = '#browse/' + Channels.cl.jid;
    },

    browseUser: function(user) {
	console.log('browseUser ' + user);
        if (this.mustLogin()) return;

        this.view.browseUser(user);
    },

    /**
     * Helper
     */
    mustLogin: function() {
        if (!Channels.cl.conn.authenticated) {
	    console.log('not authenticated, must login');
            window.location = '#login';
            return true;
        } else {
	    console.log('authenticated, alright');
            return false;
        }
    }
});
$(function() {
      new AppController();
      Backbone.history.start();
});
