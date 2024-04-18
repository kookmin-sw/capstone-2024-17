#!/bin/bash

# 스크립트 실행 시 발생할 수 있는 오류에 대해 즉시 스크립트를 중단
set -e

# Docker Compose를 사용하여 현재 실행 중인 컨테이너 종료 및 네트워크, 볼륨과 함께 제거
echo "실행 중인 컨테이너 종료 및 네트워크, 볼륨과 함께 제거 :"
sudo docker compose down

# Docker 이미지 삭제
echo "Docker 이미지 삭제 : "
docker rmi backend-was:latest mysql redis

# 애플리케이션 빌드
echo "애플리케이션 빌드 : "
chmod +x gradlew
sudo ./gradlew build

# Docker Compose를 사용하여 새로운 이미지로 컨테이너 시작
echo "새로운 이미지 생성 및 세 컨테이너 시작 : "
sudo docker compose up -d

echo "배포 성공 !!"
