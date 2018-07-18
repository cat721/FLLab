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

echo "POST request Enroll on Org2  ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4001/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim2&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".data" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"

#echo "POST request Enroll on Org2  ..."
#echo
#ORG2_TOKEN=$(curl -s -X POST \
#  http://localhost:4001/users \
#  -H "content-type: application/x-www-form-urlencoded" \
#  -d 'username=Barry&orgName=Org2')
#echo $ORG2_TOKEN
#ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".data" | sed "s/\"//g")
#echo
#echo "ORG2 token is $ORG2_TOKEN"
