# Use a lightweight Java 17 runtime
FROM eclipse-temurin:17-jdk-alpine

# Working directory inside container
WORKDIR /app

# Copy the built JAR from target (name from pom.xml)
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

# App listens on port 8089 (check application.properties)
EXPOSE 8089

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "/app/app.jar"]



