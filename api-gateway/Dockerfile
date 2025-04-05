FROM eclipse-temurin:17.0.4.1_1-jre

WORKDIR /app

ARG JAR_FILE
ARG CONFIG_DIR

# Copy the JAR file
COPY ${JAR_FILE} app.jar

# Copy configuration files
COPY ${CONFIG_DIR}/ /app/config/

EXPOSE 8080

# Set environment variables
ENV SPRING_CONFIG_LOCATION=file:/app/config/

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:8080/actuator/health/liveness || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]