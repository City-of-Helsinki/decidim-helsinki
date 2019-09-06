// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
// = require action_cable
// = require_self
// = require_tree ./channels

((exports) => {
  if (!exports.App) {
    exports.App = {}
  }

  exports.App.cable = exports.ActionCable.createConsumer();
})(window);
