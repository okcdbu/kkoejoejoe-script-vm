. ${PWD}/organizations/fabric-ca/registerEnroll.sh
. ./scripts/utils.sh
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false
REMOTE_IP="20.196.64.72"
REMOTE_PATH_BASE="/home/okcdbu/fabric-samples/test-network/organizations/fabric-ca"
LOCAL_PATH_BASE="/home/okcdbu/fabric-samples/test-network/organizations/fabric-ca"
PASSWORD="Rhlwhlwhl2475*"
USERNAME="sukamura"

# Define the directories
ORG_DIRS=("ordererOrg" "org1" "org2")

# Loop through each organization directory and download the certificate
for ORG in "${ORG_DIRS[@]}"; do
    REMOTE_PATH="$REMOTE_PATH_BASE/$ORG/tls-cert.pem"
    LOCAL_PATH="$LOCAL_PATH_BASE/$ORG/tls-cert.pem"

    echo "Downloading certificate for $ORG..."
    
    /usr/bin/sshpass -p "$PASSWORD" scp "$USERNAME@$REMOTE_IP:$REMOTE_PATH" "$LOCAL_PATH"
    
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
# 원격 VM의 주소와 사용자명 설정
#REMOTE_VM=fabric-peer

# 원격 VM에서 로컬 VM으로 MSP 디렉토리를 복사할 경로 설정
#REMOTE_ORG1_MSP="/home/okcdbu/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/msp"
#REMOTE_ORG2_MSP="/home/okcdbu/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/msp"

# 로컬 VM에 저장할 디렉토리 경로 설정
#LOCAL_ORG1_MSP="organizations/peerOrganizations/org1.example.com/msp"
#LOCAL_ORG2_MSP="organizations/peerOrganizations/org2.example.com/msp"

# 로컬 VM에 디렉토리 생성
#mkdir -p $LOCAL_ORG1_MSP
#mkdir -p $LOCAL_ORG2_MSP

# 원격 VM에서 로컬 VM으로 MSP 디렉토리 복사
#/usr/bin/sshpass -p "Rhlwhlwhl2475*" scp -r sukamura@$REMOTE_VM:$REMOTE_ORG1_MSP/* $LOCAL_ORG1_MSP/
#/usr/bin/sshpass -p "Rhlwhlwhl2475*" scp -r sukamura@$REMOTE_VM:$REMOTE_ORG2_MSP/* $LOCAL_ORG2_MSP/
#infoln "MSP 디렉토리 복사 완료"
#which configtxgen
#if [ "$?" -ne 0 ]; then
#  fatalln "configtxgen tool not found."
#fi

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
docker-compose -f docker/docker-compose-test-net.yaml up -d orderer.example.com peer0.org1.example.com peer0.org2.example.com 2>&1
docker ps -a