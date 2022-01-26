# Outputs from Terraform execution

# URL of ECR repos
output "frontend-service_URL" {
  value = aws_ecr_repository.frontend-service.repository_url
}
output "newsfeed-service_URL" {
  value = aws_ecr_repository.newsfeed-service.repository_url
}
output "quotes-service_URL" {
  value = aws_ecr_repository.quotes-service.repository_url
}
output "static-service_URL" {
  value = aws_ecr_repository.static-service.repository_url
}