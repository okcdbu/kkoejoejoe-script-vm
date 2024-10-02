#!/bin/bash

# ElasticSearch & Go 설치 및 설정 자동화 스크립트 for Ubuntu 20.04

# 1. Go 1.20 버전 다운로드 및 설치
wget https://go.dev/dl/go1.20.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.6.linux-amd64.tar.gz

# 2. Go 환경 변수 설정
export PATH=$PATH:/usr/local/go/bin
echo $PATH
# 3. ElasticSearch GPG Key 추가
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# 4. ElasticSearch 패키지 저장소 추가
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list'

# 5. 시스템 패키지 업데이트
sudo apt-get update

# 6. ElasticSearch 설치
sudo apt-get install elasticsearch -y

# 7. ElasticSearch 서비스 시작 및 자동 시작 설정
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# 8. GitHub에서 FabricSCMS 클론
git clone https://github.com/okcdbu/FabricSCMS.git

cd FabricSCMS
# 10. Go 프로그램 실행
nohup go run main.go > output.log 2>&1 &
