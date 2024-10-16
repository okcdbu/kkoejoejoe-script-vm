#!/bin/bash
# 시스템 업데이트 및 필수 패키지 설치
echo "시스템 업데이트 및 필수 패키지 설치 중..."
sudo apt-get update
sudo apt-get install -y \
            apt-transport-https \
                ca-certificates \
                    curl \
                        software-properties-common \
                            gnupg-agent

# Docker CE 설치
echo "Docker CE 설치 중..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) \
                 stable"
sudo apt-get update

# 특정 버전의 Docker 패키지 설치
sudo apt-get install -y docker-ce=5:27.0.2-1~ubuntu.20.04~focal docker-ce-cli=5:27.0.2-1~ubuntu.20.04~focal containerd.io

# Docker 서비스 시작 및 부팅 시 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# Docker 설치 확인
if sudo docker --version; then
            echo "Docker 설치 성공"
    else
                echo "Docker 설치 실패"
                    exit 1
fi

# Docker Compose 설치
echo "Docker Compose 설치 중..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chmod 666 /var/run/docker.sock
# Docker Compose 설치 확인
if sudo docker-compose --version; then
            echo "Docker Compose 설치 성공"
    else
                echo "Docker Compose 설치 실패"
                    exit 1
fi
# 공용 ip /etc/host 에 fabric-ca 추가 필요
FABRIC_CA_ADDRESS=$1
echo "Updating /etc/hosts with fabric-ca address..."
sudo -- sh -c "echo '$FABRIC_CA_ADDRESS fabric-ca' >> /etc/hosts"

# Hyperledger Fabric 설치
echo "Hyperledger Fabric 2.2 설치 중..."
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.0 1.4.7 0.4.22
# fabric-samples/test-network/organization/ordererOrg/fabric-*.yaml csr host fabric-ca 추가
curl -L -o $PWD/fabric-samples/test-network/docker/docker-compose-ca.yaml https://raw.githubusercontent.com/okcdbu/kkoejoejoe-script-vm/main/docker-compose-ca.yaml
# fabric-samples/test-network/docker 디렉토리로 이동
echo "fabric-samples/test-network/docker 디렉토리로 이동 중..."
cd ~/fabric-samples/test-network/docker || { echo "디렉토리 이동 실패"; exit 1; }

# Docker Compose를 사용하여 CA 컨테이너 실행
echo "Docker Compose를 사용하여 CA 컨테이너 실행 중..."
sudo docker-compose -f docker-compose-ca.yaml up -d

echo "스크립트 실행 완료!"