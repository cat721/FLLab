#!/bin/bash

echo
echo "========== BOOTSTRAP START =========="
echo

echo
echo "ENROLL USER $NODE_INIT_USER IN $NODE_ORG START"
echo

node bs-enroll.js

echo
echo "ENROLL USER $NODE_INIT_USER IN $NODE_ORG END"
echo

if [ "$NODE_ROLE" = "create" ]; then
	echo
	echo "CREATE CHANNEL START"
	echo
	node bs-create-channel.js
	echo
	echo "CREATE CHAHHEL END"
	echo

	echo
	echo "MYSQL LISTENER START"
	export MYSQL_HOSTNAME=192.168.1.205
	export MYSQL_PORT=12321
	export MYSQL_USER=Jim
	export MYSQL_PASSWORD=123456
	export MYSQL_DATABASE=my_db
	export MYSQL_TABLE=userinfo
	node listener.js &
	echo
fi

sleep 5

echo
echo "JOIN CHANNEL FOR USER $NODE_INIT_USER IN $NODE_ORG START"
echo

node bs-join-channel.js &

sleep 20

echo
echo "JOIN CHANNEL FOR USER $NODE_INIT_USER IN $NODE_ORG END"
echo

node app
