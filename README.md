# FLLab

## About the Structure of This Project

  - ShanghaiElectricPower

    3 peers, 1 org

  - org1, org2, org3

    3 peers, 3 orgs (3 Node.js SDK)

## How to Run Test

General steps to test the functionality of fabric based network and relevant APIs are similar, but due to different
network topology, there are minor differences

### ShanghaiElectricPower

For **ShanghaiElectricPower**, first run *bash generate.sh && bash start_network.sh* under fabric_network directory to start the network,
then start the application server using *node app.js*.
Next, run *bash a.sh* under the *oldTest* directory to create and join application channel.

#### Working With MySQL Database

To record the transactions into MySQL database and to query them using Web API later, one must ensure that mysql is running and listening
on the default port. The database named **my_db** must be prepared and a table named **userinfo** must be created in that database.
The schema of this database is as follows:

```
CREATE TABLE IF NOT EXISTS `userinfo`(
    `id` INT UNSIGNED AUTO_INCREMENT,
    `SourceId` VARCHAR(100) NOT NULL,
    `ReceiveId` VARCHAR(40) NOT NULL,
    `ServerId` VARCHAR(40) NOT NULL,
    `Value` VARCHAR(100) NOT NULL,
    `Tx_Id` VARCHAR(64) NOT NULL,
    `MyTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `Flag` boolean  NOT NULL,
    PRIMARY KEY ( `id` )
    )ENGINE=InnoDB DEFAULT CHARSET=utf8;

update userinfo set Flag = True where ReceiveId = 'b' and Flag = false;
```

What's more, a listener service must be running to listen to changes on the channel and write changes into MySQL database.
Run *node listener.js* to start this service.

Now we are ready to test the Invoke and Query Web APIs.

#### Testing Web API

To test web APIs, run *bash testAll.sh* would test Invoke API first and then test Query API. Please refer to those API documentations
for detailed explanation to the return format.

### Three Orgs

In this project there are three orgs, and org1 is responsible for starting the fabric network. The network starting sequence is very
similar to the first one, the only difference being the application channel only needs to be created once. The other orgs
can just join it. Below is the process of bring up the network till it is ready for API testing.

#### Bring up the Network

```
# Shell 1
cd org1/fabric_network # from the root directory
bash generate.sh && bash start_network.sh

# Shell 2
cd org1/fabric_network # from the root directory
PORT=4000 node app.js

# Shell 3
cd org1/fabric_network # from the root directory
bash test/enroll.sh # register user
node test/start.js # create application channel `mychannel'
node test/start1.js # join peer0.org1.example.com to `mychannel'

# Shell 4
cd org2/fabric_network # from the root directory
PORT=4001 node app.js

# Shell 5
cd org2/fabric_network # from the root directory
bash test/enroll.sh # register user
node start1.js # join peer0.org2.example.com to `mychannel'

# Shell 6
cd org3/fabric_network # from the root directory
PORT=4002 node app.js

# Shell 7
cd org3/fabric_network # from the root directory
bash test/enroll.sh # register user
node start1.js # join peer0.org3.example.com to `mychannel'
```

Also, for the database to work, we need to run *node listener.js* under org1. (Theoretically the three nodes are equally good
to run listener, but up till now only that under org1 will work.)

#### Testing Web API

This process is very similar to the previous project, just run *bash testAll.sh* under all three org directories.
