#!/bin/bash

. ${PWD}/organizations/fabric-ca/registerEnroll.sh
. ${PWD}/scripts/utils.sh
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false
REMOTE_IP="fabric-ca"
REMOTE_PATH_BASE="${PWD}/organizations/fabric-ca"
LOCAL_PATH_BASE="${PWD}/organizations/fabric-ca"
PASSWORD="Rhlwhlwhl2475*"
USERNAME="sukamura"

# Define the directories
ORG_DIRS=("ordererOrg" "org1" "org2")

# Loop through each organization directory and download the certificate
for ORG in "${ORG_DIRS[@]}"; do
    REMOTE_PATH="$REMOTE_PATH_BASE/$ORG/tls-cert.pem"
    LOCAL_PATH="$LOCAL_PATH_BASE/$ORG/tls-cert.pem"

    echo "Downloading certificate for $ORG..."
    
    sudo /usr/bin/sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no "$USERNAME@$REMOTE_IP:$REMOTE_PATH" "$LOCAL_PATH"
    
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded certificate for $ORG to $LOCAL_PATH"
    else
        echo "Failed to download certificate for $ORG"
    fi
done

# 파일 존재 확인
while :
do
  if [ ! -f "$LOCAL_PATH" ]; then
    echo "TLS 인증서 파일을 기다리는 중..."
    sleep 1
  else
    echo "TLS 인증서 파일이 성공적으로 다운로드되었습니다."
    break
  fi
done
createOrg1
createOrg2
createOrderer 
./organizations/ccp-generate.sh

infoln "Generating Orderer Genesis block"

  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
set -x
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
  fatalln "Failed to generate orderer genesis block..."
fi
sudo docker-compose -f docker/docker-compose-test-net.yaml up -d orderer.example.com peer0.org1.example.com peer0.org2.example.com 2>&1
sudo docker ps -a