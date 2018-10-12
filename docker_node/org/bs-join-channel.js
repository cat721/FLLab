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
        console.log("INSTALL SUCCESS"); 
        return
}

main()

