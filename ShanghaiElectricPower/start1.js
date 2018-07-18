require('./config.js');
var createChannel = require('./app/create-channel.js');
var join = require('./app/join-channel.js');
var install = require('./app/install-chaincode.js');
var instantiate = require('./app/instantiate-chaincode.js');

join.joinChannel("mychannel", ["peer0.org1.example.com","peer0.org2.example.com", "peer0.org3.example.com"] , "Jim", "Org1").then((msg)=>{
  console.log(msg)
    install.installChaincode(
        ["peer0.org1.example.com","peer0.org2.example.com","peer0.org3.example.com"],"mycc","github.com/example_cc/go","v0","golang", "Jim", "Org1").then((msg) => {
            instantiate.instantiateChaincode("peer0.org1.example.com","mychannel","mycc","v0","golang","init" ,["a","100","b","200"] , "Jim","Org1").then(msg => {
              console.log(msg)
            })
      })

})


