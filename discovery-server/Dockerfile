FROM eclipse-temurin:17.0.4.1_1-jre as builder
WORKDIR /app
COPY target/discovery-server-1.0-SNAPSHOT.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:17.0.4.1_1-jre
WORKDIR /app
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
EXPOSE 8761
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
