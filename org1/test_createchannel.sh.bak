rm -rf fabric-client-kv-org1

LANGUAGE="golang"

CC_SRC_PATH="github.com/example_cc/go"

"POST request Enroll on Org1  ..."
echo
TOEKN1=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')
echo $TOEKN1
TOEKN1=$(echo $TOEKN1 | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $TOEKN1"
echo
echo "POST request Enroll on Org1 ..."
echo
TOEKN2=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org1')
echo $TOEKN2
TOEKN2=$(echo $TOEKN2 | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $TOEKN2"
echo
echo

TOEKN3=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Tony&orgName=Org1')
echo $TOEKN3
TOEKN3=$(echo $TOEKN3 | jq ".token" | sed "s/\"//g")
echo
echo "ORG3 token is $TOEKN3"
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json" \
  -d '{
        "channelName":"mychannel",
        "channelConfigPath":"../artifacts/channel/channel.tx"
}'
echo
echo

sleep 5
"POST request Join channel on Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json" \
  -d '{
        "peers": ["peer0.org1.example.com","peer1.org1.example.com","peer2.org1.example.com"]
}'
echo
echo

echo "POST Install chaincode on Org1"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"peer0.org1.example.com\",\"peer1.org1.example.com\",\"peer2.org1.example.com\"],
        \"chaincodeName\":\"mycc\",
        \"chaincodePath\":\"$CC_SRC_PATH\",
        \"chaincodeType\": \"$LANGUAGE\",
        \"chaincodeVersion\":\"v0\"
}"
echo  
echo 

sleep 5 

echo "POST instantiate chaincode on peer1 of Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json" \
  -d "{
        \"chaincodeName\":\"mycc\",
        \"chaincodeVersion\":\"v0\",
        \"chaincodeType\": \"golang\",
        \"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

sleep 5
echo "POST invoke chaincode on peers of Org1"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json" \
  -d '{
        "peers": ["peer0.org1.example.com","peer1.org1.example.com","peer2.org1.example.com"],
        "fcn":"move",
        "args":["a","b","10"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo


echo "GET query chaincode on peer1 of Org1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json"
echo
echo

echo "GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json"
echo
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.example.com \
  -H "authorization: Bearer $TOEKN1" \
  -H "content-type: application/json"
echo
echo
