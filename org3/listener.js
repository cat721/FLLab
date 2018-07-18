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

var mysql      = require('mysql');
var connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'newuser',
    password : 'password',
    database : 'my_db'
});
connection.connect();

var channelName="mychannel"
helper.getClientForOrg("Org3","Jim3").then((client)=>{
    let event_hub = client.newEventHub();
  const data=fs.readFileSync(path.join(__dirname,"artifacts/channel/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt"))
    event_hub.setPeerAddr('grpcs://localhost:7053',{
      'pem':Buffer.from(data).toString(),
      'ssl-target-name-override':'peer0.org3.example.com'
    });
  event_hub.registerChaincodeEvent(
          "mycc","testWrite",
      (object) =>{
        var msg=JSON.parse(object.payload)
        var  userAddSql = 'INSERT INTO userinfo (SourceId,ReceiveId,ServerId,Value,Tx_Id,MyTime,Flag) VALUES(?,?,?,?,?,?,?)'
        var userAddSql_Params=[msg.SourceId,msg.ReceiveId,msg.SourceId,msg.Value,msg.Tx_Id,msg.Time,false]
        console.log(userAddSql_Params)
        connection.query(userAddSql,userAddSql_Params,function (err, result) {
          console.log(err)
          console.log(result)
        })
      },
      (err)=>{
        console.log(err)
      }
    )
//  event_hub.registerBlockEvent((block)=>{console.log(block)},(err)=>{console.log(err)})
  event_hub.connect()
  
}).catch((err)=>{
  console.error('errmsg: '+err)
});
