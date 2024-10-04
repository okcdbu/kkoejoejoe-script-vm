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
