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

echo "POST request Enroll on Org3  ..."
echo
ORG3_TOKEN=$(curl -s -X POST \
  http://localhost:4002/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim3&orgName=Org3')
echo $ORG3_TOKEN
ORG3_TOKEN=$(echo $ORG3_TOKEN |jq ".data" | sed "s/\"//g")
echo
echo "ORG3 token is $ORG3_TOKEN"
