
# Description

This folder contains Terraform code for Deployment Cloud Infrastructure for Application.
All resources are deployed into AWS Cloud.

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

# TBD (out of scope of MVP)

- cover Infrastructure with tests with 'terratest' <https://terratest.gruntwork.io/>
- Improve security: ACLs between all subnets - keep open only needed ports.
