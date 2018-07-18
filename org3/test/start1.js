require('../config.js');
var createChannel = require('../app/create-channel.js');
var join = require('../app/join-channel.js');
var install = require('../app/install-chaincode.js');
var instantiate = require('../app/instantiate-chaincode.js');

join.joinChannel("mychannel", [ "peer0.org3.example.com"] , "Jim3", "Org3").then((msg)=>{
  console.log(msg)
    install.installChaincode(
        ["peer0.org3.example.com"],"mycc","github.com/example_cc/go","v0","golang", "Jim3", "Org3").then((msg) => {
              console.log(msg)
      })

})


