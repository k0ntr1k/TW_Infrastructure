# Outputs from Terraform execution
# 
# Name of AWS S3 bucket to store Terraform state
output "s3_bucket" {
  value = aws_s3_bucket.terraform-state.bucket
}

# Name (Alias) of the encryption Key for AWS S3 bucket
output "kms_key" {
  value = aws_kms_alias.key-alias.id
}

# Name of DynamoDB table to store Terraform state
output "dynamodb_table" {
  value = aws_dynamodb_table.terraform-state.name
}