FROM eclipse-temurin:17.0.4.1_1-jre as builder
WORKDIR /app
COPY target/inventory-service-1.0-SNAPSHOT.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:17.0.4.1_1-jre
WORKDIR /app
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
COPY src/main/resources/application*.properties /app/config/

EXPOSE 8082

# Set environment variables
ENV SPRING_CONFIG_LOCATION=file:/app/config/

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:8082/actuator/health || exit 1

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
