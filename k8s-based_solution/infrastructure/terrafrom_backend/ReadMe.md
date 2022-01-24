
# Description

This folder contains Terraform code for initial setup Terraform Cloud backed.
Backend (Terraform State and DynamoDB) are deployed into AWS S3 bucket

# How to use

- install Terraform <https://www.terraform.io/downloads>
- setup AWS CLI <https://aws.amazon.com/cli/>
- create pair of AWS Key and AWS Key Secret <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey>
- export these Key and Secret as Environment variable:

> export AWS_ACCESS_KEY_ID="anaccesskey"
>
> export AWS_SECRET_ACCESS_KEY="asecretkey"

- execute Terraform:

> terraform init
>
> terrafrom plan & terrafrom apply

- after execution of Terrafrom copy Outputs for next step

> dynamodb_table = "..."
>
> kms_key = "..."
>
> s3_bucket = "..."

# TBD (out of scope of MVP)

- cover Infrastructure with tests with 'terratest'
