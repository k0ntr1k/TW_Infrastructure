# Outputs from Terraform execution

# URL of ECR repo
output "ECR_repo_URL" {
  value = aws_ecr_repository.tw-app-ecr.repository_url
}