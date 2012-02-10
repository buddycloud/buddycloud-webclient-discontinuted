
// backbone extensions

var once = function(event, callback) {
  var eventcb;
  return this.bind(event, eventcb = function() {
    this.unbind(event, eventcb);
    return callback.apply(this, arguments);
  });
};

Backbone.Events.once = once;
["Collection", "Model", "View"].forEach(function (cls) {
    Backbone[cls].prototype.once = once;
});


Backbone.EventHandler = (function() {
  function EventHandler() {}
  return EventHandler;
})();
_.extend(Backbone.EventHandler.prototype, Backbone.Events);
