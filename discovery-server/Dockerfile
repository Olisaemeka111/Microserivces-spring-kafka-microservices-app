FROM openjdk:17-jdk-slim

WORKDIR /app

# Default to target/*.jar but can be overridden by --build-arg
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "app.jar"]
