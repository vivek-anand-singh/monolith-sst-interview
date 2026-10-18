# syntax=docker/dockerfile:1

FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B -q dependency:go-offline
COPY src ./src
# Tests run in CI before the image is built; the integration test needs Docker, which is not available here.
RUN --mount=type=cache,target=/root/.m2 mvn -B -q clean package -DskipTests
# Split the fat jar into layers so a code-only change does not re-ship the dependencies.
RUN java -Djarmode=tools -jar target/*.jar extract --layers --launcher --destination /app/layers

FROM eclipse-temurin:17-jre
RUN groupadd --system --gid 10001 app && useradd --system --uid 10001 --gid app --no-create-home app
WORKDIR /app
COPY --from=build --chown=app:app /app/layers/dependencies/ ./
COPY --from=build --chown=app:app /app/layers/spring-boot-loader/ ./
COPY --from=build --chown=app:app /app/layers/snapshot-dependencies/ ./
COPY --from=build --chown=app:app /app/layers/application/ ./

# Declared after the COPY layers so a new commit SHA does not invalidate the cached dependency layers.
ARG GIT_SHA=unknown
LABEL org.opencontainers.image.title="interview-monolith" \
      org.opencontainers.image.revision="${GIT_SHA}"
ENV GIT_SHA=${GIT_SHA} \
    SPRING_PROFILES_ACTIVE=prod

USER 10001:10001
# 8000 serves the API; 8081 serves /actuator (health, info, prometheus) and is not routed publicly.
EXPOSE 8000 8081
# Size the heap from the container's memory limit instead of the host's.
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError"
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
