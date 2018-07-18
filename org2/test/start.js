require('../config.js');
var createChannel = require('../app/create-channel.js');
var join = require('../app/join-channel.js');
var install = require('../app/install-chaincode.js');
var instantiate = require('../app/instantiate-chaincode.js');

createChannel.createChannel("mychannel","../artifacts/channel/channel.tx" ,"Jim","Org1").then((msg)=>{

})
