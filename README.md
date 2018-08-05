# FLLab

## About the Structure of This Project

This project is funcationally the same as the master branch, the only difference being all of the programs
now runs in docker containers. This makes the program more portable and easier to deploy.

The directories and their functions are as follows:

  - SHEP: the folder that contains docker-compose file *docker-compose.yaml* to start the fabric network. The crypto
    config files are generated beforehand using the *generate.sh* script.

  - MySQL: the folder that contains the docker-compose file *docker-compose-mysql.yaml* to start mysql and
    the dockerfile *dockerfile*, which is a simple modification upon the official mysql image (5.7.22)

  - docker_node: the folder that contains the source codes (node.js) to provide the Web service. (Note the
    docker-compose file *docker-compose-sdk.yaml* is located in the SHEP folder. A bootstrap script is started
    after the container is created, the main function of this script is to create channel and join channel 
    (using node sdk). Then the node that created channel will run *listener.js* to write transaction data to the
    database.

  - test: some test scripts to test the web API, using **curl** to query and **jq** to parse JSON data.
  

## Custom Docker Images Used in This Project

  - fabric/sdk:0.1 

    used to start node.js sdk for hyperledger fabric, and to start our own web service. It is based on node image
    version 8.11.3

  - fabirc/mysql:0.1

    used to start mysql database. It is based on mysql image version 5.7.22
   
## Run the Network and Web Services

1. Start the Fabric Network

First under the SHEP folder, run

```
bash generate.sh
```
to generate the crypto files. This step is optional, if the secret keys and certificates have already been generated
this can be skipped.

Then run
```
docker-compose -f docker-compose.yaml up
```
to start the fabric network.

2. Start MySQL Database Service

If image fabric/mysql:5.7.22 have not been generated, under the MySQL folder,
run
```
docker build -t fabric/mysql:5.7.22 .
```
And then run
```
docker-compose -f docker-compose-mysql.yaml up
```
to start the MySQL database.

Note the database files are mapped from the *data* directory in the MySQL folder to increase performance.

Also note that MySQL takes about 45s to finish the initiating process (ready for connection after 45s the 
docker-compose command starts).

3. Start the Web Service

In the SHEP folder, run
```
docker-compose -f docker-compose-sdk.yaml up
```
to start the web service.

( This docker-compose file use node image 8.11.3 )

## Run the Test

Once the database, fabric network, and web serivce are running, we can test the web service using the
scripts from the test folder.

Run
```
source EnrollTestOrg{123}.sh
```
to enroll in according orgs. The source command is necessary as the access token is saved as
local shell variables.

Then run
```
source InvokeTestOrg{123}.sh
```
to test invoke APIs.

Finally run
```
source SqlTestOrg{123}.sh
```
to test SQL APIs.

## More information

If you are looking for more detailed information about this project, please refer to **README.md** in
the master branch. If that does not help you either, consider contact the team leader *cat721* at github.com.
