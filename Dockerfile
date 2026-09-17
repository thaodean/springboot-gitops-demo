# Stage 1: Build
FROM docker.io/library/eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

# Copy dependency configs first to utilize Docker layer caching
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon

# Copy source code and build the executable JAR
COPY src src
RUN ./gradlew bootJar --no-daemon

# Stage 2: Production Runtime
FROM docker.io/library/eclipse-temurin:21-jre-alpine
WORKDIR /app

# Run as a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy built JAR from builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
