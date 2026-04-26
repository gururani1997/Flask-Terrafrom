############################################
# TASK DEFINITIONS
############################################

resource "aws_ecs_task_definition" "flask" {
  family                   = "flask-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask"
      image     = "030805793658.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest"
      essential = true
      portMappings = [{
        containerPort = 8000
        hostPort      = 8000
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "MONGO_URI"
          value = "mongodb+srv://<demouser-username>:<demouser-password>@<cluster>.mongodb.net/MongoLearn?appName=<TaskName>"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/flask-backend"
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "flask"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "node" {
  family                   = "node-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "node"
      image     = "030805793658.dkr.ecr.ap-south-1.amazonaws.com/express-frontend:latest"
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "BACKEND_URL"
          value = "http://${aws_lb.app.dns_name}/api"//this place set dynamic backend Url 
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/express-frontend"
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "node"
        }
      }
    }
  ])
}

############################################
# ECS SERVICES
############################################

resource "aws_ecs_service" "flask" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_tg.arn
    container_name   = "flask"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener_rule.flask_rule,
    aws_iam_role_policy_attachment.ecs_policy
  ]
}

resource "aws_ecs_service" "node" {
  name            = "node-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.node.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.node_tg.arn
    container_name   = "node"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_policy
  ]
}
