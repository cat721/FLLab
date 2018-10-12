require('./config.js');

var instantiate = require('./app/instantiate-chaincode.js');
var fullname = process.env.NODE_FULLNAME;

instantiate.instantiateChaincode(fullname, "mychannel", "mycc", "v0", "golang", "init", ["a","100","b","200"], process.env.NODE_INIT_USER, process.env.NODE_ORG);

console.log("INSTANTIATE SUCCESS");
