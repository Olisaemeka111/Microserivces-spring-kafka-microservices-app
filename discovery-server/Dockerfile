FROM maven:3.8.5-openjdk-17-slim AS build

# Set working directory
WORKDIR /app

# Copy the parent POM
COPY pom.xml /app/

# Copy the module
COPY . /app/discovery-server/

# Build from the root directory
RUN mvn -B -f discovery-server/pom.xml clean package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/discovery-server/target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
