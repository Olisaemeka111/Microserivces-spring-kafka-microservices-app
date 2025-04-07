FROM eclipse-temurin:17.0.4.1_1-jre as builder
WORKDIR /app
COPY api-gateway/target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:17.0.4.1_1-jre
WORKDIR /app
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
COPY api-gateway/src/main/resources/application*.properties /app/config/

EXPOSE 8080

# Set environment variables
ENV SPRING_CONFIG_LOCATION=file:/app/config/

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]