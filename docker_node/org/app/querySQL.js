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
var path = require('path');
var fs = require('fs');
var util = require('util');
var hfc = require('fabric-client');
var helper = require('./helper.js');
var logger = helper.getLogger('QuerySQL');
var mysql = require('mysql');


var queryMySQL = async function(queryArgs, res) {
	logger.debug('================ QUERY MySQL ======================');
	logger.debug('host: ' + queryArgs.Hostname);
	logger.debug('user: ' + queryArgs.User);
	logger.debug('passwd: ' + queryArgs.Password);
	logger.debug('SourceID: ' + queryArgs.SourceID);
	logger.debug('ReceiveID: ' + queryArgs.ReceiveID);
	logger.debug('ServerID: ' + queryArgs.ServerID);
	logger.debug('Start Time: ' + queryArgs.STime);
	logger.debug('End Time: ' + queryArgs.ETime);
	try {
		// message to send with `res'
		message = {"state": "", "data": []};

		// first perform validity check
		if (!queryArgs.ReceiveID) {
          message.state = 1001;
          message.data = "SQL Query Condition Error: Field \"ReceiveID\" is null";
          res.send(message);
          return;
        } else if (!queryArgs.STime && queryArgs.ETime) {
          message.state = 1002;
          message.data = "SQL Query Condition Error: Field \"ETime\" is not null and field \"STime\" is null";
          res.send(message);
          return;
        }

		// construct the sql statement
		var idClause = ("ReceiveID = '" + queryArgs.ReceiveID + "'");
		if (queryArgs.sourceID) {
			idClause += (" and SourceID = '" + queryArgs.SourceID + "'");
		}
		if (queryArgs.ServerID) {
			idClause += (" and ServerID = '" + queryArgs.ServerID + "'");
		}
		var timeClause = '';
		if (!queryArgs.STime) {
			timeClause += 'Flag = false'; 
		} else if (!queryArgs.ETime) {
			timeClause += ('UNIX_TIMESTAMP(MyTime) >= UNIX_TIMESTAMP(\'' + queryArgs.STime + '\')');
		} else {
            if (Date.parse(queryArgs.STime) > Date.parse(queryArgs.ETime)) {
              logger.debug("STime > ETime");
              message.state = 1004;
              message.data = "SQL Query Condition Error: Field \"STime\" is greater than field \"ETime\"";
              res.send(message);
              return;
            }
			timeClause += ('UNIX_TIMESTAMP(MyTime) >= UNIX_TIMESTAMP(\'' + queryArgs.STime + '\')');
			timeClause += (' and UNIX_TIMESTAMP(MyTime) <= UNIX_TIMESTAMP(\'' + queryArgs.ETime + '\')');
		}
		var tableName = process.env.MYSQL_TABLE;
		var sqlQueryStmt = 'select SourceID, ReceiveID, ServerID, Value, Tx_Id, TIME_FORMAT(MyTime, "%T") as TxTime from ' + tableName + ' where ' + idClause + ' and ' + timeClause + ';'; 
		var sqlUpdateStmt = 'update ' + tableName + ' set Flag = true where ' + idClause + ' and ' + timeClause + ';';
      logger.debug('query stmt is ' + sqlQueryStmt);

		// connect to the db
		var dbName = process.env.MYSQL_DATABASE;
		var connection = mysql.createConnection({
			host: queryArgs.Hostname,
			user: queryArgs.User,
			port: queryArgs.Port,
			password: queryArgs.Password,
			database: dbName
		});

		// connection.connect(function handleConnectionError(error) {
        //   if (error) {
        //     message.state = 1003;
        //     res.send(message);
        //     //throw error;
        //   }
        // });

		// query result
		connection.query(sqlQueryStmt, function (error, result) {
			if (error) {
				logger.error('sql query \"' + sqlQueryStmt.toUpperCase() + '\" error');
				message.state = 1003; 
                message.data = "MySQL Database Connection Error";
                //message.data = "MySQL Database Query Error: Query statement is \"" + sqlQueryStmt + "\"";
				res.send(message);
			//	throw error;
			} else {
				result.forEach(function (entry) {message.data.push(entry);});
				logger.info("query result is: " + message.data);
                message.state = 500;

		        // update `Flag' field
                logger.debug("sql update stmt is " + sqlUpdateStmt.toUpperCase());
		        connection.query(sqlUpdateStmt, function (error, result) {
			    if (error) {
			    	logger.error('sql update \"' + sqlUpdateStmt.toUpperCase() + '\" error');
                    message.state = 1006;
                    message.data = "MySQL Database Update Error: Update statement is \"" + sqlUpdateStmt + "\"";
			    	res.send(message);
			    	throw error;
			    } else {
			      	res.send(message);
			    }	
		        });
			}
		});

	} catch(error) {
		logger.error(error);
	}	
};

var queryEventNum = async function (queryArgs, res) {
	try{
		logger.debug('======================= QUERY FROM EVENT NUM =======================');
		logger.debug('host: ' + queryArgs.Hostname);
		logger.debug('user: ' + queryArgs.User);
		logger.debug('passwd: ' + queryArgs.Password);
		logger.debug('EventNum: ' + queryArgs.No);

		var message = {"state":"","data": []};
	
		var connection = mysql.createConnection({
			host: queryArgs.Hostname,
			user: queryArgs.User,
			prot: queryArgs.Port,
			password: queryArgs.Password,
			database: process.env.MYSQL_DATABASE
		});

		var sqlQueryStmt = 'select SourceID, ReceiveID, ServerID, Value, Tx_Id, TIME_FORMAT(MyTime, "%T") as TxTime from ' + process.env.MYSQL_TABLE + ' where No =  ' + queryArgs.No + ' order by MyTime asc;';
         
		connection.query(sqlQueryStmt, function (error, result) {
			if(error){
				logger.error('sql query \"' + sqlQueryStmt.toUpperCase() + '\" error');
				message.state = 404;
				message.data = "MySQL Database Connection Error";
				res.send(message);
			}else {
				result.forEach(function (entry) {message.data.push(entry);});
				logger.info("query result is: " + message.data);
				message.state = 200;
				res.send(message)
			}
	 
	 
	 });
	
	} catch(error) {
		logger.error(error);
	}	


};
exports.queryMySQL = queryMySQL;
exports.queryEventNum = queryEventNum;
