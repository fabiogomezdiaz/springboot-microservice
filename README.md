# springboot-microservice

## Table of Contents

  * [Copy DevOps Files](#copy-devops-files)
    + [Copy Template Files into Existing Repo](#copy-template-files-into-existing-repo)
    + [(Gradle Only) Copy Gradle Files](#-gradle-only--copy-gradle-files)
    + [(Maven Only) Copy Maven Files](#-maven-only--copy-maven-files)
  * [Deploy on Minikube](#deploy-on-minikube)
    + [1. Start minikube](#1-start-minikube)
    + [2. Build Docker Image on Minikube's Docker Registry](#2-build-docker-image-on-minikube-s-docker-registry)
    + [3. Deploy springboot-microservice to Minikube](#3-deploy-springboot-microservice-to-minikube)
    + [4. Test the springboot-microservice service](#4-test-the-springboot-microservice-service)

## Copy DevOps Files

### Copy Template Files into Existing Repo

If you want to copy the DevOps piece of this repo into an existing repo, you can copy the following files:

```bash
# Replace with the RELATIVE or ABSOLUTE path to the root folder of your repository
REPO_FOLDER="PATH_TO_YOUR_REPO_ROOT_FOLDER"

# Create .jenkins directory in new repo
mkdir -p ../${REPO_FOLDER}/.jenkins

# Copy files
cp .gitignore ../${REPO_FOLDER}/.gitignore
cp -r config ../${REPO_FOLDER}/config
cp -r newrelic ../${REPO_FOLDER}/newrelic
cp .jenkins-eod-pod.yaml ../${REPO_FOLDER}/.jenkins-eod-pod.yaml
cp .jenkins/Jenkinsfile.groovy ../${REPO_FOLDER}/.jenkins/Jenkinsfile.groovy # The file gets renamed
```

Now open these files in the [config/deploy](config/deploy) folder and replace `springboot-microservice` with `YOUR_SERVICE_NAME` (i.e. something in the form of `svc-[gbpf|gbid|acfl]-name` such as `svc-acfl-merge`):

* [base](config/deploy/base)
  * [deployment.yml](config/deploy/base/deployment.yml)
    * On [Line 29](config/deploy/base/deployment.yml#29), make sure to replace `springboot-microservice` substring with the name of the git repository for your microservice as this is required by the Jenkins pipelines.
  * [ingress.yml](config/deploy/base/ingress.yml)
  * [service.yml](config/deploy/base/service.yml)
* [overlays](config/deploy/overlays)
  * [minikube](config/deploy/overlays/minikube)
    * [deployment.yml](config/deploy/overlays/minikube/deployment.yml)
* [envs/aws/tdock/globalid](config/deploy/envs/aws/tdock/globalid)
  * [globalid](config/deploy/envs/aws/tdock/globalid/globalid)
    * [ingress.yml](config/deploy/envs/aws/tdock/globalid/globalid/ingress.yml)

### (Gradle Only) Copy Gradle Files

If your project is Gradle based, then you need to copy these files as well:

```bash
cp -r gradle ../${REPO_FOLDER}/gradle
cp gradlew ../${REPO_FOLDER}/gradlew
cp gradlew.bat ../${REPO_FOLDER}/gradlew.bat
cp Dockerfile.gradle ../${REPO_FOLDER}/Dockerfile
```

### (Maven Only) Copy Maven Files

If your project is Maven based, then you need to copy these files as well:

```bash
cp -r .mvn ../${REPO_FOLDER}/.mvn
cp mvnw ../${REPO_FOLDER}/mvnw
cp mvnw.cmd ../${REPO_FOLDER}/mvnw.cmd
cp Dockerfile.maven ../${REPO_FOLDER}/Dockerfile
```

## Deploy on Minikube

Download the following:

* [Docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [minikube](https://minikube.sigs.k8s.io/docs/start/)
* [kubectx and kubens](https://github.com/ahmetb/kubectx#installation)

### 1. Start minikube

```bash
# Start minikube
minikube start

# If you need more memory or CPU, you can modify these flags
minikube start --memory 8192 --cpus 2

# Just in case, switch to minikube context
kubectx minikube

# Just in case, switch to the default namespace in minikube
kubens default
```

### 2. Build Docker Image on Minikube's Docker Registry

Since we don't have access to push/pull a Docker image to/from Artifactory from minikube, we need to build our microservice image directly into minikube's Docker Daemon.

Before we do so, we need to change the [Dockerfile](Dockerfile) to use the base images from Docker Hub.

TODO: FIX THESE

Now, you need to point the `docker client` CLI in your workstation to the `docker daemon` that is running inside of `minikube` in order to build and save the microservice docker image directly into minikube's `docker daemon`. This is done by setting some environment variables in your current shell session.

Conveniently, minikube provides a command that prints out those environment variables, which you then need to apply or evaluate into your current shell session.

To do so, run the following command based on your shell:

**Note:** The following command will ONLY work on your existing shell session/tab. If you want to run builds in other shell sessions/tabs, you need to run the following command on all those shells.

```bash
# Set docker env
eval $(minikube -p minikube docker-env)             # Unix Shells
minikube -p minikube docker-env | Invoke-Expression # PowerShell
```

Now, in the same shell, run any of the following commands:

```bash
# Build image
docker build -t minikube/springboot-microservice:latest -f Dockerfile .

# List the images and verify that the above image is listed
docker images
```

If you can see the `minikube/springboot-microservice:latest` image listed similarly to how it's shown in the output below, then the image has been successfully built into minikube's Docker Daemon and it is ready to be used.

```bash
REPOSITORY                         TAG                   IMAGE ID       CREATED         SIZE
minikube/springboot-microservice          latest                65ab40f9ece5   4 hours ago     251MB
```

### 3. Deploy springboot-microservice to Minikube

This repo uses [kustomize](https://kustomize.io/) to deploy applications into Kubernetes. You can install `kustomize` as a separate binary, but as of [kubectl v1.14](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/), `kustomize` is included as a subcommand of `kubectl`.

It's recommended that you watch the following video to understand the basics of `kustomize`:

[![Simplify Kubernetes YAML with Kustomize](https://img.youtube.com/vi/5gsHYdiD6v8/0.jpg)](http://www.youtube.com/watch?v=5gsHYdiD6v8 "Simplify Kubernetes YAML with Kustomize")

The Kubernetes YAML files are stored in the [config/deploy](config/deploy) directory, which in most repos is broken down as follows:

```bash
config
└── deploy
    ├── base # This directory contains the base YAML files
    │   ├── deployment.yml
    │   ├── kustomization.yml
    │   └── service.yml
    ├── overlays # This overrides "base"
    │   ├── aws
    │   │   └── kustomization.yml
    │   └── minikube # We will be using THIS folder to override the contents of "base"
    │       ├── deployment.yml
    │       └── kustomization.yml
    └── envs # Ignore for now, but this overrides "overlays", which then overrides "base" for a specific NAMESPACE in a specific kubernetes CLUSTER
        └── aws
            └── tdock
                └── globalid # CLUSTER
                    └── globalid # NAMESPACE
                        ├── ingress.yml
                        └── kustomization.yml
```

Now that we understand the basics of Kustomize, we can proceed with deploying the microservice with the command below:

```bash
# This will generate and print the YAML for you to inspect, if desired
kubectl kustomize config/deploy/overlays/minikube

# This will generate and deploy the YAML
kubectl apply -k config/deploy/overlays/minikube
```

### 4. Test the springboot-microservice service

On a separate terminal, run a port forward to the `springboot-microservice` service, as follows:

```bash
kubectl port-forward service/springboot-microservice 8080:8080
```

**NOTE:** Feel free to change `8080:8080` to `8081:8080` or another port if port `8080` is currently in use in your workstation.

Then open the following URL on your browser:

* <http://localhost:8080/actuator/health>

If you are able to successful health check, then you have successfully deployed and tested the `springboot-microservice` service!!!

**NOTE**: Feel free to do additional testing from here.

