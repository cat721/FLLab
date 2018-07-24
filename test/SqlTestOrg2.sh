#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

echo "++++++++++++ SqlTest.sh START +++++++++"
echo
echo 

echo "POST invoke chaincode on peers of Org2 for the first time"
echo

time1=$(date "+%Y-%m-%d %H:%M:%S")
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.example.com"],
	"fcn":"invoke",
	"args":["a","b","a","a"]
}')
echo "Transaction ID is $TRX_ID"
echo
echo

time2=$(date "+%Y-%m-%d %H:%M:%S")

echo "POST invoke chaincode on peers of Org2 for the second time"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.example.com"],
	"fcn":"invoke",
	"args":["a","b","a","a"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

time3=$(date "+%Y-%m-%d %H:%M:%S")

echo "POST invoke chaincode on peers of Org2 for the third time"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.example.com"],
	"fcn":"invoke",
	"args":["a","b","a","a"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

time4=$(date "+%Y-%m-%d %H:%M:%S")

echo "+++++++++++++Starting Test MYSQL+++++++++"
echo "Test no STime and NO ETime"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"Hostname":"192.168.1.205",
	"Port": "12321",
	"User":"Jim",
	"Password":"123456",
	"SourceID":"a",
	"ReceiveID":"b",
	"ServerID":"a"
}')
echo "Transacton ID is $TRX_ID"
echo
echo


echo "Test no STime and NO ETime after alter flag"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"Hostname":"192.168.1.205",
	"Port": "12321",
	"User":"Jim",
	"Password":"123456",
	"SourceID":"a",
	"ReceiveID":"b",
	"ServerID":"a"
}')
echo "Query Result is $TRX_ID"
echo
echo


echo "Test no SSTime and have ETime"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"Hostname\":\"192.168.1.205\",
	\"Port\": \"12321\",
	\"User\":\"Jim\",
	\"Password\":\"123456\",
	\"SourceID\":\"a\",
	\"ReceiveID\":\"b\",
	\"ServerID\":\"a\",
	\"ETime\":\"$time1\"
  }")
echo "Query Result is $TRX_ID"


echo "Test both have SSTime and ETime"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"Hostname\":\"192.168.1.205\",
	\"Port\": \"12321\",
	\"User\":\"Jim\",
	\"Password\":\"123456\",
	\"SourceID\":\"a\",
	\"ReceiveID\":\"b\",
	\"ServerID\":\"a\",
	\"STime\":\"$time3\",
	\"ETime\":\"$time4\"
}")
echo "Query Result is $TRX_ID"
echo
echo


echo "Test have SSTime and no ETime"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"Hostname\":\"192.168.1.205\",
	\"Port\": \"12321\",
	\"User\":\"Jim\",
	\"Password\":\"123456\",
	\"SourceID\":\"a\",
	\"ReceiveID\":\"b\",
	\"ServerID\":\"a\",
	\"STime\":\"$time1\"
  }")
echo "Query Result is $TRX_ID"
echo
echo

echo "Test no ReceiveID"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"Hostname\":\"192.168.1.205\",
	\"Port\": \"12321\",
	\"User\":\"Jim\",
	\"Password\":\"123456\",
	\"SourceID\":\"a\",
	\"ServerID\":\"a\"
  }")
echo "Query Result is $TRX_ID"
echo
echo

echo "Test connect mysql error"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/data \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"Hostname\":\"192.168.1.205\",
	\"Port\": \"12321\",
	\"User\":\"nosuchuser\",
	\"Password\":\"password\",
	\"SourceID\":\"a\",
	\"ReceiveID\":\"b\",
	\"ServerID\":\"a\",
	\"STime\":\"$time1\"
}")
echo "Query Result is $TRX_ID"
echo
echo

echo "time1: $time1"
echo "time2: $time2"
echo "time3: $time3"
echo "time4: $time4"

echo 
echo
echo "++++++++++++ SqlTest.sh END +++++++++"
