(function() {
  var BOSH_SERVICE, Connection;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  BOSH_SERVICE = 'http://bosh.metajack.im:5280/xmpp-httpbind';
  Connection = (function() {
    function Connection() {
      this.afterConnected = __bind(this.afterConnected, this);;
      this.onIq = __bind(this.onIq, this);;
      this.onConnect = __bind(this.onConnect, this);;      this.connected = false;
      this.roster = new UserCollection;
      this.roster.localStorage = new Store("Roster");
      this.roster.fetch();
      _.extend(this, Backbone.Events);
    }
    Connection.prototype.connect = function(jid, password) {
      this.c = new Strophe.Connection(BOSH_SERVICE);
      this.jid = jid;
      this.password = password;
      this.user = Users.findOrCreateByJid(this.jid);
      this.connector = new Connector(this.c);
      this.bind('connected', this.afterConnected);
      return this.c.connect(this.jid, this.password, this.onConnect);
    };
    Connection.prototype.onConnect = function(status) {
      if (status === Strophe.Status.CONNECTING) {
        return this.trigger('connecting');
      } else if (status === Strophe.Status.AUTHFAIL) {
        return this.trigger('authfail');
      } else if (status === Strophe.Status.CONNFAIL) {
        this.connected = false;
        return this.trigger('connfail');
      } else if (status === Strophe.Status.DISCONNECTING) {
        return this.trigger('disconnecting');
      } else if (status === Strophe.Status.DISCONNECTED) {
        this.connected = false;
        return this.trigger('disconnected');
      } else if (status === Strophe.Status.CONNECTED) {
        this.connected = true;
        return this.trigger('connected');
      }
    };
    Connection.prototype.onIq = function(iq) {
      this.connector.onIq(iq);
      return true;
    };
    Connection.prototype.afterConnected = function() {
      console.log("acon", arguments);
      this.connector.announcePresence(this.user);
      this.c.addHandler(this.onIq, null, 'iq');
      return true;
    };
    return Connection;
  })();
  this.Connection = Connection;
}).call(this);
