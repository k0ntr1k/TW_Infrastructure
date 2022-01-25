#!/bin/sh
# Prerequisites for Build App
brew install leiningen
brew install openjdk

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
cp ./build/front-end.jar ../k8s-based_solution/app_images/front-end_service/
cp ./build/newsfeed.jar ../k8s-based_solution/app_images/newsfeed_service/
cp ./build/quotes.jar ../k8s-based_solution/app_images/quotes_service/
cp -R ./front-end/public ../k8s-based_solution/app_images/static_assets/
cd ..
rm -rf application

echo Autenticate in ECR
# Authenticate in Private ECR registry
# URL of ECR need to be replaces from Terrafrom output
# aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 776120585128.dkr.ecr.eu-central-1.amazonaws.com

# Building Docker image for FrontendService
cd k8s-based_solution/app_images/
echo Build 'frontend' Image
cd front-end_service/
docker build -t frontend-service .
rm *.jar

# Building Docker image for newsfeedService
echo Build 'newsfeed' Image
cd ../newsfeed_service/
docker build -t newsfeed-service .
rm *.jar

# Building Docker image for quotesService
echo Build 'quotes' Image
cd ../quotes_service/
docker build -t quotes-service .
rm *.jar

echo Build 'static assests' Image
cd ../static_assests/
docker build -t static-assets-service .
rm -rf 

echo -------------------------------------------------------
echo Building Images DONE! 
echo Enjoy with HELM
echo -------------------------------------------------------