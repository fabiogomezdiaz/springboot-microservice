.PHONY: build install clean

# Variables
APP_NAME = springboot-microservice
APP_VERSION = '0.0.1-SNAPSHOT'
JAVA_VERSION = 11.0.20-tem
TAG = latest

sdkman:
	@echo "Installing SDKMAN..."
	@curl -s "https://get.sdkman.io" | bash
	@source "$HOME/.sdkman/bin/sdkman-init.sh"
	@echo "SDKMAN installed."

java:
	@echo "Installing Java..."
	@sdk install java $(JAVA_VERSION)
	@echo "Java installed."

clean:
	@echo "Cleaning build directory..."
	@rm -rf build target
	@echo "Build directory cleaned."

#########
# Bazel #
#########

bazel:
	@echo "Building $(APP_NAME)..."
	@bazel build //:springboot_microservice --java_runtime_version=remotejdk_11
	@echo "Build completed."

bazel-clean:
	@echo "Cleaning Bazel cache..."
	@bazel clean --expunge
	@echo "Bazel cache cleaned."

bazel-lib:
	@echo "Building $(APP_NAME)..."
	@bazel build //:springboot_microservice_lib --java_runtime_version=remotejdk_11
	@echo "Build completed."

bazel-test:
	@echo "Testing $(APP_NAME)..."
	@bazel test //:springboot_microservice_test --java_runtime_version=remotejdk_11
	@echo "Test completed."

bazel-run:
	@echo "Running $(APP_NAME)..."
	@bazel run //:springboot_microservice --java_runtime_version=remotejdk_11

##########
# Gradle #
##########
gradle-build: install
	@echo "Building $(APP_NAME)..."
	@./gradlew build
	@echo "Build completed."

gradle-run:
	@echo "Running $(APP_NAME)..."
	@java -jar build/libs/$(APP_NAME)-$(APP_VERSION).jar

gradle-docker:
	@echo "Building Docker image"
	@DOCKER_BUILDKIT=1 docker build -t $(APP_NAME):gradle -f Dockerfile.gradle .
	@echo "Docker image built"

gradle-docker-run:
	@echo "Running Docker image"
	@docker stop $(APP_NAME)-gradle || true
	@docker run --rm --name $(APP_NAME)-gradle -p 8080:8080 -d $(APP_NAME):gradle
	@echo "Docker image running"

gradle-docker-logs:
	@echo "Showing Docker logs"
	@docker logs -f $(APP_NAME)-gradle

gradle-docker-shell:
	@echo "Opening shell in Docker container"
	@docker exec -it $(APP_NAME)-gradle /bin/sh

gradle-docker-stop:
	@echo "Stopping Docker container"
	@docker stop $(APP_NAME)-gradle

#########
# Maven #
#########
maven-build: install
	@echo "Building $(APP_NAME)..."
	@./mvnw package
	@echo "Build completed."

maven-run:
	@echo "Running $(APP_NAME)..."
	@java -jar target/$(APP_NAME)-$(APP_VERSION).jar

maven-docker:
	@echo "Building Docker image"
	@DOCKER_BUILDKIT=1 docker build -t $(APP_NAME):maven -f Dockerfile.maven .
	@echo "Docker image built"

maven-docker-run:
	@echo "Running Docker image"
	@docker stop $(APP_NAME)-maven || true
	@docker run --rm --name $(APP_NAME)-maven -p 8080:8080 -d $(APP_NAME):maven
	@docker run --rm --name springboot-microservice-maven -p 8080:8080 -d springboot-microservice:maven
	@echo "Docker image running"

maven-docker-logs:
	@echo "Showing Docker logs"
	@docker logs -f $(APP_NAME)-maven

maven-docker-shell:
	@echo "Opening shell in Docker container"
	@docker exec -it $(APP_NAME)-maven /bin/sh

maven-docker-stop:
	@echo "Stopping Docker container"
	@docker stop $(APP_NAME)-maven

##########
# Docker #
##########

docker-clean:
	@echo "Cleaning Docker images and containers"
	@docker system prune -a --volumes

################
# Abache Bench #
################
load-test:
	@echo "Running Apache Bench"
	@ab -n 1000000 -c 100 http://localhost:8080/helloworld