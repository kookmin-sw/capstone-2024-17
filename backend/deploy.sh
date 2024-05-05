#!/bin/bash

# 스크립트 실행 시 발생할 수 있는 오류에 대해 즉시 스크립트를 중단
set -e

# 전체 컨테이너 재시작
############################################
echo "<< 전체 컨테이너 삭제 >>"
sudo docker compose down

echo "<< 전체 이미지 삭제 >>"
sudo docker rmi $(sudo docker images -q)

echo "<< spring app 빌드 >>"
chmod +x gradlew
sudo ./gradlew build

echo "<< 전체 재배포 >>"
sudo docker compose up -d

echo "<< 배포 성공 !! >>"
