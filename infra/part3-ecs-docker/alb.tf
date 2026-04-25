
############################################
# APPLICATION LOAD BALANCER
############################################

resource "aws_lb" "app" {
  name               = "app-alb"
  load_balancer_type = "application"

  # MUST be multiple subnets
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  security_groups = [aws_security_group.alb_sg.id]
}

############################################
# TARGET GROUP - FLASK
############################################

resource "aws_lb_target_group" "flask_tg" {
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    matcher             = "200"
  }
}

############################################
# TARGET GROUP - NODE
############################################

resource "aws_lb_target_group" "node_tg" {
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

############################################
# LISTENER (DEFAULT → NODE)
############################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_tg.arn
  }
}

############################################
# RULE → FLASK (/api)
############################################

resource "aws_lb_listener_rule" "flask_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}
