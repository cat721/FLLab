/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
'use strict';
require('./config.js')
var path = require('path');
var fs = require('fs');
var util = require('util');
var hfc = require('fabric-client');
var helper = require('./app/helper.js');
var logger = helper.getLogger('invoke-chaincode');

var channelName="mychannel"
helper.getClientForOrg("Org1","Jim").then((client)=>{
		logger.debug('Successfully got the fabric client for the organization org1');
		var channel = client.getChannel(channelName);
		if(!channel) {
			let message = util.format('Channel %s was not defined in the connection profile', channelName);
			logger.error(message);
			throw new Error(message);
		}

			// wait for the channel-based event hub to tell us
			// that the commit was good or bad on each peer in our organization
			let eh= channel.getChannelEventHub("peer1.org1.example.com");
				logger.debug('invokeEventPromise - setting up event');
  
  //eh.registerBlockEvent((block)=>{console.log(block)},(err)=>{console.log(err)})
					eh.registerChaincodeEvent("mycc","testWrite", (object) => {
                      console.log(object)
                      //var msg=JSON.parse(object.payload)
                      console.log("message")
                      //console.log(msg)
					}, (err) => {
                      console.log("error")
						logger.error(err);
					},
						// the default for 'unregister' is true for transaction listeners
						// so no real need to set here, however for 'disconnect'
						// the default is false as most event hubs are long running
						// in this use case we are using it only once
						//{unregister: true, disconnect:true}
					);
					eh.connect();
}).catch((err)=>{
  console.error('errmsg: '+err)
});
