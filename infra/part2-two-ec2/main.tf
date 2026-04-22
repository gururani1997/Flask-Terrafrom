# ---------------- BACKEND SECURITY GROUP ----------------
resource "aws_security_group" "backend_sg" {
  name = "backend-sg"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- FRONTEND SECURITY GROUP ----------------
resource "aws_security_group" "frontend_sg" {
  name = "frontend-sg"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- BACKEND EC2 (FLASK) ----------------
resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = file("backend-user-data.sh")

  tags = {
    Name = "Backend-flask"
  }
}

# ---------------- FRONTEND EC2 (EXPRESS) ----------------
resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = "dev-pankj"


  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  user_data = file("frontend-user-data.sh")

  tags = {
    Name = "Frontend-express"
  }
}
