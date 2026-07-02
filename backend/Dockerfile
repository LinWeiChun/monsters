FROM eclipse-temurin:18-jdk AS build

WORKDIR /app
COPY gradle ./gradle
COPY gradlew settings.gradle build.gradle ./
COPY src ./src

RUN ./gradlew bootJar --no-daemon

FROM eclipse-temurin:18-jre

WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
