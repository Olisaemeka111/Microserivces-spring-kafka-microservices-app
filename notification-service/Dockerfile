FROM eclipse-temurin:17.0.4.1_1-jre
WORKDIR /app

# JAR_FILE can be an absolute path
ARG JAR_FILE
COPY ${JAR_FILE} app.jar

EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
