FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app

# Copy the parent POM first
COPY pom.xml /app/parent-pom.xml

# Create directory for the module
RUN mkdir -p /app/discovery-server

# Copy the module POM and source code
COPY pom.xml /app/discovery-server/
COPY src /app/discovery-server/src/

# Build from the module directory with reference to parent
WORKDIR /app/discovery-server
RUN mvn clean package -DskipTests -Dparent.relativePath=../parent-pom.xml

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
