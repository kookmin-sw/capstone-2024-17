#!/bin/bash

# 스크립트 실행 시 발생할 수 있는 오류에 대해 즉시 스크립트를 중단
set -e

# Docker Compose를 사용하여 현재 실행 중인 컨테이너 종료 및 네트워크, 볼륨과 함께 제거
echo "Stopping existing Docker containers...!"
sudo docker compose down

# Docker 이미지 삭제
echo "Removing existing Docker images...!"
docker rmi backend-was:latest mysql redis

# 애플리케이션 빌드
echo "Building the application...!"
chmod +x gradlew
sudo ./gradlew build

# Docker Compose를 사용하여 새로운 이미지로 컨테이너 시작
echo "Starting new Docker containers...!"
sudo docker compose up -d

echo "Deployment complete !!"
