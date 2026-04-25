############################################
# ECS CLUSTER (if not in ecs.tf)
############################################

resource "aws_ecs_cluster" "main" {
  name = "app-cluster"
}

############################################
# OPTIONAL: CLOUDWATCH LOG GROUP (safe add)
############################################

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/app-logs"
  retention_in_days = 7
}

############################################
# NOTE:
# If you already defined these in other files:
# - VPC
# - ALB
# - ECS services
# - ECR
# DO NOT duplicate them here
############################################
