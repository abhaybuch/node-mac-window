const active_app = require('bindings')('active_app.node');

module.exports = {
	makeKeyAndOrderFront: active_app.makeKeyAndOrderFront
}