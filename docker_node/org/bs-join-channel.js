require('./config.js');
var join = require('./app/join-channel.js');
var install = require('./app/install-chaincode.js');
var instantiate = require('./app/instantiate-chaincode.js');

var fullname = process.env.NODE_FULLNAME;
var main = async function() {
	let msgJoin = await join.joinChannel(
		"mychannel", [fullname], process.env.NODE_INIT_USER, process.env.NODE_ORG);
	let msgInstall = await install.installChaincode(
		[fullname], "mycc","github.com/example_cc/go", "v0", "golang", process.env.NODE_INIT_USER, process.env.NODE_ORG);
	let msgInst = await instantiate.instantiateChaincode(
		fullname, "mychannel", "mycc", "v0", "golang", "init", ["a","100","b","200"], process.env.NODE_INIT_USER, process.env.NODE_ORG);
        console.log("INSTANTIATE SUCCESS"); 
        return
}

main()

