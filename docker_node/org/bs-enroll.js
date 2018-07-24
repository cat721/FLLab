'use strict';
require('./config.js');
var hfc = require('fabric-client');

var helper = require('./app/helper.js');

var response = helper.getRegisteredUser(process.env.NODE_INIT_USER, process.env.NODE_ORG, true);
console.log("response is\n%s", response);
