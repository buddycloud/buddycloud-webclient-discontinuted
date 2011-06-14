(function() {
  var Jid;
  Jid = (function() {
    function Jid(jid) {
      this.jid = jid;
    }
    Jid.prototype.getDomain = function() {
      return this.jid.replace(/.+?@/, '').replace(/\/.+/, '');
    };
    Jid.prototype.getNode = function() {
      return this.jid.replace(/@.+/, '');
    };
    Jid.prototype.buddycloudDomain = function() {
      return (this.getDomain() === "buddycloud.com") || (this.getDomain() === "diaspora-x.com");
    };
    return Jid;
  })();
  this.Jid = Jid;
}).call(this);
