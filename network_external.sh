#!/bin/bash

. ${PWD}/organizations/fabric-ca/registerEnroll.sh
. ${PWD}/scripts/utils.sh
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false
REMOTE_IP="fabric-ca"

LOCAL_PATH_BASE="${PWD}/organizations/fabric-ca"
REMOTE_PATH_BASE="${PWD}/organizations/fabric-ca"
# Define the directories
ORG_DIRS=("ordererOrg" "org1" "org2")

# Loop through each organization directory and download the certificate
for ORG in "${ORG_DIRS[@]}"; do
    REMOTE_PATH="$REMOTE_PATH_BASE/$ORG/tls-cert.pem"
    LOCAL_PATH="$LOCAL_PATH_BASE/$ORG/tls-cert.pem"

    echo "Downloading certificate for $ORG..."
    
    sudo scp -i ${PWD}/../../temp.pem -o StrictHostKeyChecking=no "$USER@$REMOTE_IP:$REMOTE_PATH" "$LOCAL_PATH"
    
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
sudo docker-compose -f docker/docker-compose-test-net.yaml up -d 2>&1
sudo docker ps -a
echo "Orderer 노드가 리더를 선출할 때까지 1분 대기합니다."
sleep 60
./scripts/createChannel.sh mychannel 3 5 false
# 1. scmsinstall.sh 파일을 GitHub에서 다운로드
wget https://raw.githubusercontent.com/okcdbu/kkoejoejoe-script-vm/main/scmsinstall.sh -O scmsinstall.sh
# 2. 다운로드한 파일에 실행 권한 부여
chmod +x scmsinstall.sh
# fabric-samples/test-network 디렉토리로 이동
cd fabric-samples/test-network/

# 환경 변수 설정
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export PATH=$PATH:${PWD}/../bin/
export FABRIC_CFG_PATH=${PWD}/../config/
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 상위 디렉토리로 이동
cd ../../
# 3. scmsinstall.sh 실행
./scmsinstall.sh