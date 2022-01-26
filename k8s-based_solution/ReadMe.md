## How-To Build and Deploy Application

#### Prerequisites
  - install Terraform <https://www.terraform.io/downloads>
  - setup AWS CLI <https://aws.amazon.com/cli/>
  - create pair of AWS Key and AWS Key Secret <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey>
  - export these Key and Secret as Environment variable:

    > export AWS_ACCESS_KEY_ID="anaccesskey"
    >
    > export AWS_SECRET_ACCESS_KEY="asecretkey"

#### How to use

  1. Go to `infrastructure/terraform_backend` folder and execute Terraform.
    
  This step will prepare backend infrastructure for Terraform. Using Cloud storage for Terraform state. A remote back end is an absolute must if you have multiple people managing the same infrastructure. In that scenario, you need to share the state — as you might end up stepping into each other’s shoes, and that exponentially increases complexity with the number of people added.
      
  Next resources will be created:
  - AWS S3 Storage Acccount for Terraform state bucket
  - AWS KMS Key for encrypting the state
  - DynamoDB Table for storing the state

  * execute Terraform:

    > terraform init
    >
    > terrafrom plan & terrafrom apply

  * after execution of Terrafrom copy Outputs for next step

    > dynamodb_table = "..."
    >
    > kms_key = "..."
    >
    > s3_bucket = "..."

  Please copy these values into `../application_backend/main.tf` file in `backend "s3" {}` section

*---------------------------------------------------------------------------------------------------------------------*

  2. Go to `infrastructure/application_backend` folder and execute Terraform.

  This step will Deploy main Cloud Infrastructure for Application.

  Next resources will be created:
  - AWS EKS Cluster for Application
  - AWS ECR Repository for Docker Images
  - AWS VPC (Virtual Network) with ElasticIP

  * execute Terraform:

    > terraform init
    >
    > terrafrom plan & terrafrom apply
  
  * after execution of Terrafrom copy Outputs for next step

    > clusterURL = "..."
    >
    > *_repoURL = "..."

    Paste these values into bash scripts '2_BUILD_and_PUSH.sh' and '3_DEPLOY_APP.sh' in `application_backend/scripts` folder.

*---------------------------------------------------------------------------------------------------------------------*
- **Build and Push Images into Container Registry**

  Please replace Variables from Terraform output.

  Execute `2_BUILD_and_PUSH.sh`

  This script will build services into Docker Images and pushing them to ECR.
  Every microservice will be packed in separate Dockerfile.
  List of microservices:
    - frontend_service
    - newsfeed_service
    - quotes_service
    - static_service

  All needed packages will be installed automatically before execution (Only for MacOS - brew).

*---------------------------------------------------------------------------------------------------------------------*
- **Deploy Application**
  
  Please replace Variables from Terraform output.

  Execute `3_DEPLOY_APP.sh`

This script automatically install all dependencies (MacOS only) and will deploy all microservices into EKS Cluster with HELM.

Environment variables for Microservices are set in `values.yaml` file.

Secret for access to ECR Repository as well as Token for Newsfeed is set as Kubernetes Secret.

*---------------------------------------------------------------------------------------------------------------------*
## TBD
- cover Infrastructure with tests with 'terratest' <https://terratest.gruntwork.io/>
- Scalability with Kubernetes
- Improve security of Infrastructure: VPC, EKS, ECR - with ACL, SecurityGroups, IAM Roles, etc.
- Improve frontend security with HTTPS connection
- Organize monitoring for Application and Infrastructure. (CloudWatch, CloudTrail, CloudWatch Logs, Datadog, etc.)
- Organize Logging for Application and Infrastructure. (CloudWatch, CloudWatch Logs, Datadog, etc.)
- Organize Backup for Application and Infrastructure