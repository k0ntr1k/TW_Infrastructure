# How-To install and Run the Application

# Prerequisites

## AWS
### Install & Configure AWS CLI
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
### Create AWS Access Key and Secret
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey

### Configure and use Terraform
#### Export the AWS credentials
> export AWS_ACCESS_KEY_ID="anaccesskey"
>
> export AWS_SECRET_ACCESS_KEY="asecretkey"

#### Create Terraform State backend
> cd ../Terraform/State/
> terraform init & terraform apply
>

copy Terraform output ("s3_bucket", "kms_key" and "dynamodb_table"), paste it into /Terraform/Infrastructure/main.tf file.

### Create App Infrastructure on AWS 
> cd ../Terraform/Infrastructure/
>
> terraform init & terraform apply
