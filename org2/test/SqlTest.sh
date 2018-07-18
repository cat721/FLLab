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

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/example_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

# echo "POST request Enroll on Org2  ..."
# echo
# ORG2_TOKEN=$(curl -s -X POST \
#   http://localhost:4001/users \
#   -H "content-type: application/x-www-form-urlencoded" \
#   -d 'username=Jim2&orgName=Org2')
# echo $ORG2_TOKEN
# ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".data" | sed "s/\"//g")
# echo
# echo "ORG2 token is $ORG2_TOKEN"

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
	"Hostname":"localhost",
    "User":"newuser",
    "Password":"password",
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
	"Hostname":"localhost",
    "User":"newuser",
    "Password":"password",
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
\"Hostname\":\"localhost\",
\"User\":\"newuser\",
\"Password\":\"password\",
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
	\"Hostname\":\"localhost\",
    \"User\":\"newuser\",
    \"Password\":\"password\",
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
	\"Hostname\":\"localhost\",
    \"User\":\"newuser\",
    \"Password\":\"password\",
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
	\"Hostname\":\"localhost\",
    \"User\":\"newuser\",
    \"Password\":\"password\",
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
    \"Hostname\":\"localhost\",
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


# echo "Test ETime smaller than STime"
# TRX_ID=$(curl -s -X POST \
#   http://localhost:4001/data \
#   -H "authorization: Bearer $ORG2_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#     \"Hostname\":\"localhost\",
#     \"User\":\"newuser\",
#     \"Password\":\"password\",
#     \"SourceID\":\"a\",
#     \"ReceiveID\":\"b\",
#     \"ServerID\":\"smaller\",
#     \"ETime\":\"$time1\",
#     \"STime\":\"$time4\"
# }")
# echo "Query Result is $TRX_ID"
# echo
# echo

echo "time1: $time1"
echo "time2: $time2"
echo "time3: $time3"
echo "time4: $time4"

echo 
echo
echo "++++++++++++ SqlTest.sh END +++++++++"
