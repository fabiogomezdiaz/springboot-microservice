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

build: install
	@echo "Building $(APP_NAME)..."
	@./gradlew build
	@echo "Build completed."

build-maven: install
	@echo "Building $(APP_NAME)..."
	@./mvnw package
	@echo "Build completed."

run:
	@echo "Running $(APP_NAME)..."
	@java -jar build/libs/$(APP_NAME)-$(APP_VERSION).jar

run-maven:
	@echo "Running $(APP_NAME)..."
	@java -jar target/$(APP_NAME)-$(APP_VERSION).jar

docker:
	@echo "Building Docker image"
	@DOCKER_BUILDKIT=1 docker build -t $(APP_NAME):$(TAG) .
	@echo "Docker image built"

docker-maven:
	@echo "Building Docker image"
	@DOCKER_BUILDKIT=1 docker build -t $(APP_NAME):$(TAG)-maven .
	@echo "Docker image built"

docker-run:
	@echo "Running Docker image"
	@docker stop $(APP_NAME) || true
	@docker run --rm --name $(APP_NAME) -p 3000:80 -d $(APP_NAME):$(TAG)
	@echo "Docker image running"

docker-run-maven:
	@echo "Running Docker image"
	@docker stop $(APP_NAME) || true
	@docker run --rm --name $(APP_NAME)-maven -p 3000:80 -d $(APP_NAME):$(TAG)-maven
	@echo "Docker image running"

docker-logs:
	@echo "Showing Docker logs"
	@docker logs -f $(APP_NAME)

docker-logs-maven:
	@echo "Showing Docker logs"
	@docker logs -f $(APP_NAME)-maven

docker-shell:
	@echo "Opening shell in Docker container"
	@docker exec -it $(APP_NAME) /bin/sh

docker-shell-maven:
	@echo "Opening shell in Docker container"
	@docker exec -it $(APP_NAME)-maven /bin/sh

docker-stop:
	@echo "Stopping Docker container"
	@docker stop $(APP_NAME)

docker-stop-maven:
	@echo "Stopping Docker container"
	@docker stop $(APP_NAME)-maven