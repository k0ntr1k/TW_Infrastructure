#!/bin/sh
# Prerequisites for Build App
brew install leiningen
brew install openjdk
brew install docker
brew install awscli

# Define variables
ECR_URL=776120585128.dkr.ecr.eu-central-1.amazonaws.com # URL of ECR need to be replaces from Terrafrom output

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

echo Autenticate in ECR
# Authenticate in Private ECR registry
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${ECR_URL}

# Building Docker image for FrontendService
cd k8s-based_solution/app_images/
echo Build 'frontend-service' Image
cd frontend-service/
docker build -t frontend-service .
echo Tag 'frontend-service' image
docker tag frontend-service:latest ${ECR_URL}/frontend-service:latest
echo Push 'frontend-service' image to ECR
docker push ${ECR_URL}/frontend-service:latest
rm *.jar

# Building Docker image for newsfeedService
echo Build 'newsfeed-service' Image
cd ../newsfeed-service/
docker build -t newsfeed-service .
echo Tag 'newsfeed-service' image
docker tag newsfeed-service:latest ${ECR_URL}/newsfeed-service:latest
echo Push 'newsfeed-service' image to ECR
docker push ${ECR_URL}/newsfeed-service:latest
rm *.jar

# Building Docker image for quotesService
echo Build 'quotes-service' Image
cd ../quotes-service/
docker build -t quotes-service .
echo Tag 'quotes-service' image
docker tag quotes-service:latest ${ECR_URL}/quotes-service:latest
echo Push 'quotes-service' image to ECR
docker push ${ECR_URL}/quotes-service:latest
rm *.jar

echo Build 'static-service' Image
cd ../static-service/
docker build -t static-service .
echo Tag 'static-service' image
docker tag static-service:latest ${ECR_URL}/static-service:latest
echo Push 'static-service' image to ECR
docker push ${ECR_URL}/static-service:latest
rm -rf public

echo -------------------------------------------------------
echo Building Images DONE!
echo -------------------------------------------------------
echo Enjoy with HELM and K8S!
cd ../../
./3_DEPLOY_APP.sh
echo -------------------------------------------------------