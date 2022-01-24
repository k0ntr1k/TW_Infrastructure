# Deploying Application and App backend into Cloud.

## Tools:

### **AWS** as a cloud provider

- **AWS EKS** - Kubernetes on AWS

- **AWS ECR** - Docker Registry

### **TERRAFORM** for deploying infrastructure

### **DOCKER** for building microservices as a Images for future deployments

### **HELM** for deploying Services into AWS EKS


## How-To Build and Deploy Application

- **Deploy Cloud Infrastructure**

  1. Go to `infrastructure/terraform_backend` folder and execute Terraform.

    This step will Deploy all needed Cloud Infrastructure for Terraform. More information and steps for executing you can find in 'ReadMe.md' file.

  2. Go to `infrastructure/application_backend` folder and execute Terraform.

    This step will Deploy main Cloud Infrastructure for Application. Will be deployed EKS, ECR and all needed network Infrastructure. More information and steps for executing you can find in 'ReadMe.md' file.

- **Build and Push Images into Container Registry**

  Execute `BUILD_and_PUSH.sh`

    This will build services and Docker Images and pushing them to ECR.
    More information and steps for executing you can find in 'ReadMe.md' file.

- **Deploy Application**

    Go to `helm_charts` folder and execute HELM.

    This will Deploy Application into Kubernetes. More information and steps for executing you can find in 'ReadMe.md' file.
