# Outputs from Terraform execution

# URL of ECR repos
output "frontend-service_repoURL" {
  value = aws_ecr_repository.frontend-service.repository_url
}
output "newsfeed-service_repoURL" {
  value = aws_ecr_repository.newsfeed-service.repository_url
}
output "quotes-service_repoURL" {
  value = aws_ecr_repository.quotes-service.repository_url
}
output "static-service_repoURL" {
  value = aws_ecr_repository.static-service.repository_url
}
output "clusterURL"{
  value = module.eks.cluster_arn
}