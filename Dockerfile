# Multi-stage Dockerfile: build with Maven, run with lightweight JRE
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml pom.xml
COPY src src
# Download dependencies and build
RUN mvn -B -DskipTests clean package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /workspace/target/demo-0.0.1-SNAPSHOT.jar /app/demo.jar
EXPOSE 8080
ENV JAVA_OPTS="-Xms128m -Xmx512m"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/demo.jar"]
