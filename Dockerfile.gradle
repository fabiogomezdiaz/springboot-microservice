# STAGE: Build
FROM gradle:7.5.0-jdk11 as builder

# Create Working Directory
ENV BUILD_DIR=/home/build
RUN mkdir $BUILD_DIR
WORKDIR $BUILD_DIR

# Download Dependencies
COPY build.gradle settings.gradle ${BUILD_DIR}/
RUN gradle build -x test --continue

# Copy Source
COPY src src

# Skip Tests
ARG SKIP_TESTS="-x test"

# Build JAR
#RUN gradle build ${SKIP_TESTS}
 RUN gradle build

# Rename JAR
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN PROJECT_NAME="$(gradle properties -q | grep 'name:' | awk '{print $2}')" && \
    PROJECT_VERSION="$(gradle properties -q | grep 'version:' | awk '{print $2}')" && \
    export PROJECT_NAME && \
    export PROJECT_VERSION &&\
    mv "${BUILD_DIR}/build/libs/${PROJECT_NAME}-${PROJECT_VERSION}.jar" "${BUILD_DIR}/build/libs/app.jar"

# STAGE: Deploy
FROM openjdk:11-jre-slim-buster

# Non-Root User
ENV USERNAME=appuser
ENV GROUP=$USERNAME
ENV USER_UID=1001
ENV USER_GID=$USER_UID

# Create app directory
ENV APP_HOME=/home/app
RUN mkdir -p $APP_HOME
RUN addgroup --gid $USER_GID $GROUP && \
    adduser --uid $USER_UID --gid $USER_GID $USERNAME
WORKDIR $APP_HOME

# Copy JAR file over from builder stage
COPY --from=builder --chown=$USER_UID:$USER_GID /home/build/build/libs/app.jar $APP_HOME
RUN chmod 700 app.jar

USER $USERNAME

EXPOSE 8080

CMD ["java", "-jar", "./app.jar"]
