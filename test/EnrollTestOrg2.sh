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

echo "POST request Enroll on Org2  ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4001/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim2&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN |jq ".data" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"
