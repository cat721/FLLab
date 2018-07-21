
networkDown() {
  docker-compose -f $COMPOSE_FILE down --volumes --remove-orphans
    docker run -v $PWD:/tmp/balance-transfer-artifacts --rm hyperledger/fabric-tools:$IMAGETAG rm -Rf /tmp/balance-transfer-artifacts/ledgers-backup
    #Cleanup the chaincode containers
    clearContainers
    #Cleanup images
    removeUnwantedImages
    # remove orderer block and other channel configuration transactions and certs
    # remove the docker-compose yaml file that was customized to the example
}

function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /artifacts_default-peer.*.mycc.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | grep "artifacts_default\|dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

BLACKLISTED_VERSIONS="^1\.0\. ^1\.1\.0-preview ^1\.1\.0-alpha"

function checkPrereqs() {
  # Note, we check configtxlator externally because it does not require a config file, and peer in the
  # docker image because of FAB-8551 that makes configtxlator return 'development version' in docker
  LOCAL_VERSION=$(configtxlator version | sed -ne 's/ Version: //p')
  DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-tools:$IMAGETAG peer version | sed -ne 's/ Version: //p' | head -1)

  echo "LOCAL_VERSION=$LOCAL_VERSION"
  echo "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"
:
  if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
    echo "=================== WARNING ==================="
    echo "  Local fabric binaries and docker images are  "
    echo "  out of  sync. This may cause problems.       "
    echo "==============================================="
  fi

  for UNSUPPORTED_VERSION in $BLACKLISTED_VERSIONS; do
    echo "$LOCAL_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
      echo "ERROR! Local Fabric binary version of $LOCAL_VERSION does not match this newer version of BYFN and is unsupported. Either move to a later version of Fabric or checkout an earlier version of fabric-samples."
      exit 1
    fi

    echo "$DOCKER_IMAGE_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
      echo "ERROR! Fabric Docker image version of $DOCKER_IMAGE_VERSION does not match this newer version of BYFN and is unsupported. Either move to a later version of Fabric or checkout an earlier version of fabric-samples."
      exit 1
    fi
  done
}
function cleanCreds() {
  if [ -d "../fabric-client-kv-org1" ];
    rm -rf "../fabric-client-kv-org1"
  fi
  if [ -d "../../org2/fabric-client-kv-org2" ];
    rm -rf "../../org2/fabric-client-kv-org2"
  fi
  if [ -d "../../org3/fabric-client-kv-org3" ];
    rm -rf "../../org3/fabric-client-kv-org3"
  fi
  
}

CHANNEL_NAME="mychannel"
# use this as the default docker-compose yaml definition
COMPOSE_FILE=docker-compose.yaml
# use golang as the default language for chaincode
LANGUAGE=golang
# default image tag
IMAGETAG="latest"
cleanCreds
checkPrereqs
networkDown
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker-compose -f $COMPOSE_FILE up  2>&1
