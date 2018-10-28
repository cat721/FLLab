###How to restart the peer node when the container of peer becomes down
First change the workspace to FLLab/SHEP/fabric_network

Then stop the docker container peer0.org1.example.com & org1_sdk

```
docker stop peer0.org1.example.com
docker stop org1_sdk
```

restart the docker container peer0.org1.example.com & org1_sdk

```
docker start peer0.org1.example.com
docker start org1_sdk
```
