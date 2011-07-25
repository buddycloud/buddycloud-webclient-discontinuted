
// backbone extensions

Backbone.Events.once = function(event, callback) {
  var eventcb;
  return this.bind(event, eventcb = function() {
    this.unbind(event, eventcb);
    return callback.apply(this, arguments);
  });
};

Backbone.EventHandler = (function() {
  function EventHandler() {}
  return EventHandler;
})();
_.extend(Backbone.EventHandler.prototype, Backbone.Events);
