var connect = require('connect');
var serveStatic = require('serve-static');
console.log("SERVER LAUNCHED");
connect().use(serveStatic(__dirname)).listen(8080);