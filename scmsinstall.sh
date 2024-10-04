#!/bin/bash

# ElasticSearch & Go 설치 및 설정 자동화 스크립트 for Ubuntu 20.04

# 1. Go 1.20 버전 다운로드 및 설치
wget https://go.dev/dl/go1.20.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.6.linux-amd64.tar.gz

# 2. Go 환경 변수 설정
export PATH=$PATH:/usr/local/go/bin
echo $PATH

sudo docker run -d --name elasticsearch -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.9.0

# 8. GitHub에서 FabricSCMS 클론
git clone https://github.com/okcdbu/FabricSCMS.git

cd FabricSCMS
# 10. Go 프로그램 실행
nohup go run main.go > output.log 2>&1 &

lsof -i :8080

# Node.js 설치 (최신 버전)
# Ubuntu/Debian 기반 배포판의 경우
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs

# git 설치 (필요한 경우)
sudo apt-get install -y git

# GitHub 리포지토리 클론
git clone https://github.com/okcdbu/smartContractAPI.git

# 디렉토리 변경
cd smartContractAPI || { echo "디렉토리 변경 실패"; exit 1; }

# npm 패키지 설치
npm install --force

# 애플리케이션 시작
npm start
