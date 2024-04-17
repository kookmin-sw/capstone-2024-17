FROM openjdk:17.0.1-jdk
RUN apt-get update && apt-get install -y iputils-ping redis-tools # ping and redis-cli
ADD /build/libs/backend-0.0.1-SNAPSHOT.jar spring-app.jar
ENTRYPOINT ["java", "-jar", "/spring-app.jar"]
