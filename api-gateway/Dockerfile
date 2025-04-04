FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app

# Copy the parent POM first
COPY pom.xml /app/parent-pom.xml

# Create directory for the module
RUN mkdir -p /app/api-gateway

# Copy the module POM and source code
COPY pom.xml /app/api-gateway/
COPY src /app/api-gateway/src/

# Build from the module directory with reference to parent
WORKDIR /app/api-gateway
RUN mvn clean package -DskipTests -Dparent.relativePath=../parent-pom.xml

FROM eclipse-temurin:17.0.4.1_1-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]