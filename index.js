const mac_window = require("bindings")("mac_window.node");

module.exports = {
  makeKeyAndOrderFront: mac_window.makeKeyAndOrderFront,
};
