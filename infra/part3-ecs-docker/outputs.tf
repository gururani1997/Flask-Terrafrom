output "flask_repo_url" {
  value = aws_ecr_repository.flask.repository_url
}

output "node_repo_url" {
  value = aws_ecr_repository.node.repository_url
}