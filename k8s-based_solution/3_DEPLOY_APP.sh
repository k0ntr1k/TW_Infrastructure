#!/bin/sh
# Prerequisites for Deploying App
brew install helm
brew install awscli
brew install kubectl

# Define variables
ECR_URL= # URL of ECR need to be replaces from Terrafrom output
REGION=eu-central-1 # AWS region of deployment need to be replaces from Terrafrom output
EKS_CLUSTER_NAME= # EKS cluster name need to be replaces from Terrafrom output
SECRET_NAME=app-ecr-registry-secret
NAMESPACE=test-app

# Authenticate into EKS Cluster
echo -------------------------------------------------------
echo Authenticate into EKS Cluster
aws eks update-kubeconfig --region ${REGION} --name ${EKS_CLUSTER_NAME}

# Autenticate ECR in EKS Cluster
echo -------------------------------------------------------
echo Autenticate ECR in EKS Cluster
TOKEN=`aws ecr --region=${REGION} get-authorization-token --output text --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2`

kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
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
  echo Service $service deployed
  echo -------------------------------------------------------
done

echo Enjoy with next steps!
echo -------------------------------------------------------