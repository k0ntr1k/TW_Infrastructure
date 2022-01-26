#!/bin/sh
# Prerequisites for Build App
brew install leiningen
brew install openjdk
brew install docker
brew install awscli

# Define variables
ECR_URL= # URL of ECR need to be replaces from Terrafrom output
REGION=eu-central-1 # AWS region of deployment need to be replaces from Terrafrom output
DOCKER_BUILDX_OPT='buildx'
DOCKER_BUILD_OPT='--no-cache --squash --force-rm --compress'
DOCKER_PLATFORM_OPT='--platform=linux/amd64'

# Download Application from GitHub
# URL: https://github.com/ThoughtWorksInc/infra-problem/archive/refs/heads/master.zip 
# Build App, create Docker Images and push into ECR
echo Download Application from GitHub
mkdir ../application
curl https://github.com/ThoughtWorksInc/infra-problem/archive/refs/heads/master.zip -o ../application/master.zip -L 
cd ../application
unzip ../application/master.zip -d .
mv ../application/infra-problem-master/* .
rm -rf infra-problem-master
echo -------------------------------------------------------
echo Build Application
make test
make libs
make clean all
echo -------------------------------------------------------
echo Build Docker images with Application components
# Copy JAR files into app_images directory
cp ./build/front-end.jar ../k8s-based_solution/app_images/frontend-service/
cp ./build/newsfeed.jar ../k8s-based_solution/app_images/newsfeed-service/
cp ./build/quotes.jar ../k8s-based_solution/app_images/quotes-service/
cp -R ./front-end/public ../k8s-based_solution/app_images/static-service/
cd ..
rm -rf application

echo Authenticate runner in ECR
# Authenticate in Private ECR registry
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URL}

# Building Docker image for FrontendService
cd k8s-based_solution/app_images/
echo Build 'frontend-service' Image
cd frontend-service/
docker ${DOCKER_BUILDX_OPT} build ${DOCKER_BUILD_OPT} -t frontend-service . ${DOCKER_PLATFORM_OPT}
echo Tag 'frontend-service' image
docker tag frontend-service:latest ${ECR_URL}/frontend-service:latest
echo Push 'frontend-service' image to ECR
docker push ${ECR_URL}/frontend-service:latest
rm *.jar

# Building Docker image for newsfeedService
echo Build 'newsfeed-service' Image
cd ../newsfeed-service/
docker ${DOCKER_BUILDX_OPT} build ${DOCKER_BUILD_OPT} -t newsfeed-service . ${DOCKER_PLATFORM_OPT}
echo Tag 'newsfeed-service' image
docker tag newsfeed-service:latest ${ECR_URL}/newsfeed-service:latest
echo Push 'newsfeed-service' image to ECR
docker push ${ECR_URL}/newsfeed-service:latest
rm *.jar

# Building Docker image for quotesService
echo Build 'quotes-service' Image
cd ../quotes-service/
docker ${DOCKER_BUILDX_OPT} build ${DOCKER_BUILD_OPT} -t quotes-service . ${DOCKER_PLATFORM_OPT}
echo Tag 'quotes-service' image
docker tag quotes-service:latest ${ECR_URL}/quotes-service:latest
echo Push 'quotes-service' image to ECR
docker push ${ECR_URL}/quotes-service:latest
rm *.jar

echo Build 'static-service' Image
cd ../static-service/
docker ${DOCKER_BUILDX_OPT} build ${DOCKER_BUILD_OPT} -t static-service . ${DOCKER_PLATFORM_OPT}
echo Tag 'static-service' image
docker tag static-service:latest ${ECR_URL}/static-service:latest
echo Push 'static-service' image to ECR
docker push ${ECR_URL}/static-service:latest
rm -rf public

echo -------------------------------------------------------
echo Building and Pushing Images to AWS ECR DONE!
echo -------------------------------------------------------