# DEMO FIXTURE. The base images below are deliberately upstream Docker Hub
# images. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: intermediate. The classic Maven build / JRE runtime split.
# Expected: comment only on the maven stage, one-click suggestion on the JRE
# runtime stage.

FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /workspace

COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q -DskipTests package

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build /workspace/target/ledger-0.1.0.jar /app/ledger.jar

EXPOSE 8080

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/ledger.jar"]
