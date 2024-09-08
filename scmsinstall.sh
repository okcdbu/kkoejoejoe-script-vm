#!/bin/bash

# ElasticSearch 설치 및 설정 자동화 스크립트 for Ubuntu 20.04

# 1. ElasticSearch GPG Key 추가
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# 2. ElasticSearch 패키지 저장소 추가
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list'

# 3. 시스템 패키지 업데이트
sudo apt-get update

# 4. ElasticSearch 설치
sudo apt-get install elasticsearch -y

# 5. ElasticSearch 서비스 시작 및 자동 시작 설정
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# 6. ElasticSearch 상태 확인
sudo systemctl status elasticsearch

# 7. GitHub에서 FabricSCMS 클론
git clone https://github.com/okcdbu/FabricSCMS.git

# 8. 클론한 디렉터리로 이동
cd FabricSCMS

# 9. Go 프로그램 실행
go run main.go
