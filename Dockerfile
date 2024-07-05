q# Extract the Spring Boot Application into Layers
FROM eclipse-temurin:21-jre as builder
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /application.jar
RUN java -Djarmode=tools -jar /application.jar extract --destination /out --application-filename app.jar

# Create a multi layer file
FROM eclipse-temurin:21-jre
WORKDIR /application
COPY --from=builder /out/lib /application/lib
COPY --from=builder /out/app.jar /application/app.jar
ENTRYPOINT ["java","-Dspring.aot.enabled=true", "-jar", "app.jar"]
