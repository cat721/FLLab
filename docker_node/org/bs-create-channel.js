require('./config.js');
var createChannel = require('./app/create-channel.js');

createChannel.createChannel("mychannel","../artifacts/channel/channel.tx",process.env.NODE_INIT_USER,process.env.NODE_ORG).then((msg)=>{})
