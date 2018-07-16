# README for testing chaincode invoke API interface and MySQL database query interface

## Starting the Network

First generate the network artifacts (genesis block, certificates, secret keys, etc) using the *generate.sh* script under the fabric_network directory, then run the script *start_network.sh* to bring down existing network and start lhe fabric network.

```
bash generate.sh
bash start_network.sh
```

## Create and Join Channel

To create and join application channel, run the script a.sh under the root directory.

```
bash a.sh
```

## Start API Server

The server is hosted using Node.js framework. To start the server, run app.js script. (If dependencies was not met, try *npm install* under the root directory.)

```
node app.js
``` 

## Test the API

To fully test the chaincode invoking and MySQL database querying interfaces, we have designed many test cases to cover almost all the success and failure cases. The test cases are
placed in the script *testAll.sh*. Run this script and all the tests will begin.

```
bash testAll.sh
```
