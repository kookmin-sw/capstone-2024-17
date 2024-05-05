#!/bin/bash

# 스크립트 실행 시 발생할 수 있는 오류에 대해 즉시 스크립트를 중단
set -e

# spring-service 컨테이너만 재시작
############################################
echo "<< spring-service 삭제 시도 >>"
sudo docker compose stop spring-service
echo "y" | sudo docker compose rm spring-service
if docker images | grep -w backend-was; then
  docker rmi backend-was # 이미지 삭제
fi

# 애플리케이션 빌드 시도
echo "<< spring app 빌드 >>"
chmod +x gradlew
sudo ./gradlew build

# 재시작 시도
echo "<< spring-service 재빌드 및 재시작 >>"
if sudo docker compose up -d --no-deps spring-service; then
    echo "<< spring-service 배포 성공 !! >>"
else
    echo "<< spring-service 재시작 실패 >>"
    echo "<< [전체 재시작] 모든 컨테이너, 이미지 삭제 >>"
    sudo docker compose down # 실행 중인 모든 컨테이너 종료 및 제거
    docker rmi backend-was:latest mysql redis # 모든 관련 이미지 삭제

    echo "<< [전체 재시작] 재배포 >>"
    sudo docker compose up -d

    echo "<< [전체 재시작] 배포 성공 !! >>"
fi
