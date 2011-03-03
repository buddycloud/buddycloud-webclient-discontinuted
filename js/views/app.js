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

    show: function() {
        $(this.el).show();
    },
    hide: function() {
        $(this.el).hide();
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
        this.login = new LoginView();
        this.view = new AppView();
    },

    routes: {
        'login': 'login',
        '': 'index',
        'browse/:user': 'browseUser'
    },

    login: function() {
        if (this.mustLogin()) {
            this.view.hide();
            this.login.show();

            var that = this;
            var success = function() {
                Channels.cl.unbind('online', success);
                console.log({'login success':Channels.cl});
                window.location = '#';
            };
            Channels.cl.bind('online', success);
        } else {
            window.location = '#';
        }
    },

    index: function() {
        if (this.mustLogin()) return;

        this.login.hide();
        this.view.show();

        /* Forward to own channel */
        this.location = '#browse/' + Channels.cl.jid;
    },

    browseUser: function(user) {
        if (this.mustLogin()) return;

        this.view.browseUser(user);
    },

    /**
     * Helper
     */
    mustLogin: function() {
        if (!Channels.cl.conn.authenticated) {
            window.location = '#login';
            return true;
        } else {
            return false;
        }
    }
});
$(function() {
      new AppController();
      Backbone.history.start();
});
