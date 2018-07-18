
function replacePrivateKey() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp docker-compose-template.yaml docker-compose.yaml
 
  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  cd crypto-config/peerOrganizations/org1.example.com/ca/
  CA1_PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA1_PRIVATE_KEY/${CA1_PRIV_KEY}/g" docker-compose.yaml

  cd crypto-config/peerOrganizations/org2.example.com/ca/
  CA2_PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA2_PRIVATE_KEY/${CA2_PRIV_KEY}/g" docker-compose.yaml

  cd crypto-config/peerOrganizations/org3.example.com/ca/
  CA3_PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA3_PRIVATE_KEY/${CA3_PRIV_KEY}/g" docker-compose.yaml

#config org1  network config 
  cd crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/
  ADMIN_PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  cd ../artifacts/

 if [ -e network-config.yaml ] ;then
     echo "overriding existing network-config.yaml"
    rm -rf network-config.yaml
 fi
  cp network-config-temple.yaml network-config.yaml

  sed $OPTS "s/ORG1PRIVATEKEY/${ADMIN_PRIV_KEY}/g" network-config.yaml

##config org2 network config 
  cd "$CURRENT_DIR"
  cd crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/
  ADMIN_PRIV_KEY=$(ls *_sk)

  cd "$CURRENT_DIR"
  cd ../../org2/artifacts/

 if [ -e network-config.yaml ] ;then
     echo "overriding existing network-config.yaml"
    rm -rf network-config.yaml
 fi
  cp network-config-temple.yaml network-config.yaml

  sed $OPTS "s/ORG1PRIVATEKEY/${ADMIN_PRIV_KEY}/g" network-config.yaml

##config org3 network config
  cd "$CURRENT_DIR"
  cd crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp/keystore/
  ADMIN_PRIV_KEY=$(ls *_sk)

  cd "$CURRENT_DIR"
  cd ../../org3/artifacts/

 if [ -e network-config.yaml ] ;then
     echo "overriding existing network-config.yaml"
    rm -rf network-config.yaml
 fi
  cp network-config-temple.yaml network-config.yaml

  sed $OPTS "s/ORG1PRIVATEKEY/${ADMIN_PRIV_KEY}/g" network-config.yaml


  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm docker-compose.yaml
  fi

  cd "$CURRENT_DIR"
}

function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile OneOrgOrderersGenesis -outputBlock ./channel-artifacts/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile OneOrgChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
}


CHANNEL_NAME="mychannel"
OS_ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
CURRENT_DIR=${PWD}

generateCerts
generateChannelArtifacts
replacePrivateKey

##config org1 sdk configuration
if [ -d ../artifacts/channel/crypto-config ]; then
    echo "overriding existing crypto config directory"
    rm -rf ../artifacts/channel/crypto-config
fi

if [ -e ../artifacts/channel/*.tx ] ;then
     echo "overriding existing .tx"
    rm -f ../artifacts/channel/*.tx
fi

if [ -e ../artifacts/channel/*.block ] ;then
     echo "overriding existing genesis block"
    rm -f ../artifacts/channel/*.block
fi
cp -r crypto-config ../artifacts/channel/
cp -r channel-artifacts/* ../artifacts/channel/

##config org2 sdk configuration
if [ -d ../../org2/artifacts/channel/crypto-config ]; then
    echo "overriding existing crypto config directory"
    rm -rf ../../org2/artifacts/channel/crypto-config
fi

if [ -e ../../org2/artifacts/channel/*.tx ] ;then
     echo "overriding existing .tx"
    rm -f ../../org2/artifacts/channel/*.tx
fi

if [ -e ../../org2/artifacts/channel/*.block ] ;then
     echo "overriding existing genesis block"
    rm -f ../../org2/artifacts/channel/*.block
fi
cp -r crypto-config ../../org2/artifacts/channel/
cp -r channel-artifacts/* ../../org2/artifacts/channel/

##config org3 sdk configuration
if [ -d ../../org3/artifacts/channel/crypto-config ]; then
    echo "overriding existing crypto config directory"
    rm -rf ../../org3/artifacts/channel/crypto-config
fi

if [ -e ../../org3/artifacts/channel/*.tx ] ;then
     echo "overriding existing .tx"
    rm -f ../../org2/artifacts/channel/*.tx
fi

if [ -e ../../org3/artifacts/channel/*.block ] ;then
     echo "overriding existing genesis block"
    rm -f ../../org3/artifacts/channel/*.block
fi
cp -r crypto-config ../../org3/artifacts/channel/
cp -r channel-artifacts/* ../../org3/artifacts/channel/
