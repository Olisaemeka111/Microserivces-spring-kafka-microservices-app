FROM maven:3.8.5-openjdk-17-slim AS build

# Set working directory
WORKDIR /app

# Copy the parent POM
COPY pom.xml /app/

# Copy the module
COPY . /app/api-gateway/

# Build from the root directory
RUN mvn -B -f api-gateway/pom.xml clean package -DskipTests

FROM eclipse-temurin:17.0.4.1_1-jre
WORKDIR /app
COPY --from=build /app/api-gateway/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]