#!/bin/sh
# Prerequisites for Deploying App
brew install helm
brew install awscli
brew install kubectl

# Define variables
ECR_URL=776120585128.dkr.ecr.eu-central-1.amazonaws.com # URL of ECR need to be replaces from Terrafrom output
REGION=eu-central-1 # AWS region of deployment need to be replaces from Terrafrom output
SECRET_NAME=tw-app-ecr-registry-secret
NAMESPACE=test-app

# Authenticate into EKS Cluster
echo -------------------------------------------------------
echo Authenticate into EKS Cluster
# aws eks update-kubeconfig --region ${REGION} --name tw-eks-test-cluster

# Autenticate ECR in EKS Cluster
echo -------------------------------------------------------
echo Autenticate ECR in EKS Cluster
TOKEN=`aws ecr --region=${REGION} get-authorization-token --output text --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2`

kubectl delete secret --ignore-not-found ${SECRET_NAME}
kubectl create secret docker-registry ${SECRET_NAME} \
 --namespace=${NAMESPACE} \
 --docker-server=https://${ECR_URL} \
 --docker-username=AWS \
 --docker-password="${TOKEN}" \
 --docker-email="email@email.com"

echo -------------------------------------------------------
echo Deploy Application
cd helm_charts
for service in 'static-service' 'quotes-service' 'newsfeed-service' 'frontend-service'; do
  echo Deploy $service
  helm upgrade --install --create-namespace -n ${NAMESPACE} $service $service/ --values $service/values.yaml
done

echo -------------------------------------------------------
echo Enjoy with next steps!
echo -------------------------------------------------------