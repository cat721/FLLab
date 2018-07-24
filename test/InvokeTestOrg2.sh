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

echo "++++++++++++++ Invoke TEST START ++++++++++++++++++"
echo
echo

echo "correct version"
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
echo "invoke with not existing peer"
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer1.org2.example.com"],
	"fcn":"invoke",
	"args":["a","b","a","a"]
}')
echo "Transaction ID is $TRX_ID"
echo
echo


echo "invoke with error number of parameter"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4001/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.example.com"],
	"fcn":"invoke",
	"args":["a","b","a","a","addition parameter"]
}')
echo "Transacton ID is $TRX_ID"
echo

echo "++++++++++++++ Invoke TEST END ++++++++++++++++++"
echo
echo
