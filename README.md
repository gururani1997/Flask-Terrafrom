# 🚀 Flask-Terraform – Terraform AWS Deployment

This project demonstrates **Infrastructure as Code (IaC)** using Terraform to deploy a full-stack application across three different AWS architectures.

The application consists of:

* **Frontend**: Node.js + Express → Port **3000**
* **Backend**: Python + Flask → Port **8000**
* **Database**: MongoDB Atlas

---

## 🧠 Project Objective

Deploy the same full-stack application in **three progressively advanced architectures** using Terraform — starting from a single EC2 all the way to a fully containerised cloud-native setup on ECS Fargate.

---

## 📁 Project Structure

```text
FLASK-TERRAFORM/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── infra/
│   ├── part1-single-ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── security-group.tf
│   ├── part2-multi-ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── vpc.tf
│   │   └── security-group.tf
│   └── part3-ecs/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── ecr.tf
│       ├── vpc.tf
│       ├── alb.tf
│       ├── ecs.tf
│       └── iam.tf
├── docker-compose.yaml
└── README.md
```

---

## ☁️ Technologies Used

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure provisioning and management |
| AWS EC2 | Virtual machines for Parts 1 and 2 |
| AWS VPC | Isolated networking for all parts |
| AWS ECR | Private Docker image registry for Part 3 |
| AWS ECS Fargate | Serverless container runtime for Part 3 |
| AWS ALB | Load balancer and path-based routing for Part 3 |
| AWS IAM | Execution role granting ECS access to ECR and CloudWatch |
| Docker | Containerising Flask and Express apps |
| Node.js + Express | Frontend application on port 3000 |
| Python + Flask | Backend API on port 8000 |
| MongoDB Atlas | Cloud-hosted database |

---

## 🔧 Pre-Requisites

Install the following tools before running any part:

```bash
# Verify AWS CLI is configured
aws configure list

# Verify Terraform version (>= 1.3 required)
terraform -version

# Verify Docker is running
docker info

# Verify Node.js
node -version

# Verify Python
python3 --version
```

Configure AWS credentials:

```bash
aws configure
# Enter: Access Key ID, Secret Key, region (ap-south-1), output (json)
```

---

## 🔹 Part 1 — Single EC2 Deployment

### Objective

Run both Flask (port **8000**) and Express (port **3000**) on a **single EC2 instance** using a Cloud-Init user data script to install dependencies and start both apps automatically on boot.

### Architecture

```
Internet
   │
   ▼
EC2 Instance (Public IP)
├── Express  → :3000
└── Flask    → :8000
```

### Terraform Files

| File | Purpose |
|---|---|
| `main.tf` | EC2 instance with user\_data script to install Python, Node.js and start both apps |
| `variables.tf` | Region, AMI ID, instance type — change once, applies everywhere |
| `security-group.tf` | Opens ports 22 (SSH), 3000 (Express), 8000 (Flask) to the internet |
| `outputs.tf` | Prints EC2 public IP after apply |

### User Data Script

```bash
#!/bin/bash
apt-get update -y
apt-get install -y python3-pip nodejs npm

# Start Flask backend on port 8000
pip3 install flask pymongo
nohup python3 /app/backend/app.py &

# Start Express frontend on port 3000
cd /app/frontend && npm install
nohup node server.js &
```

### Deploy

```bash
cd infra/part1-single-ec2

terraform init        # Download AWS provider
terraform fmt         # Format .tf files
terraform validate    # Check syntax
terraform plan        # Preview resources
terraform apply       # Create EC2 instance
terraform output      # Get public IP
```

### Verify

```bash
# Express frontend
curl http://<EC2-PUBLIC-IP>:3000

# Flask backend
curl http://<EC2-PUBLIC-IP>:8000
```

---

## 🔹 Part 2 — Multi EC2 Deployment

### Objective

Deploy Flask and Express on **two separate EC2 instances** inside a custom VPC. Security groups allow inter-instance communication while both remain publicly accessible.

### Architecture

```
Internet
   │
   ├──▶ EC2 Flask Instance  → :8000  (Flask SG)
   │
   └──▶ EC2 Node Instance   → :3000  (Node SG)
          │
          └──▶ Calls Flask via private IP
```

### Terraform Files

| File | Purpose |
|---|---|
| `vpc.tf` | Custom VPC (10.0.0.0/16), public subnet, internet gateway, route table |
| `security-group.tf` | Flask SG: port 8000 public; Node SG: port 3000 public; both allow inbound from each other |
| `main.tf` | Two EC2 instances each with their own user\_data |
| `variables.tf` | Region, AMI, instance type, key pair |
| `outputs.tf` | Exports `flask_public_ip` and `node_public_ip` |

### Deploy

```bash
cd infra/part2-multi-ec2

terraform init
terraform plan
terraform apply
terraform output flask_public_ip   # Open http://<ip>:8000
terraform output node_public_ip    # Open http://<ip>:3000
```

### Verify

```bash
# Flask backend
curl http://<FLASK-IP>:8000

# Express frontend
curl http://<NODE-IP>:3000
```

---

## 🔹 Part 3 — Containerised Deployment (ECS Fargate)

### Objective

Dockerise both apps, push images to **AWS ECR**, run as **Fargate** tasks, and route traffic through a single **ALB** using path-based rules — `/api/*` goes to Flask on port **8000**, everything else goes to Express on port **3000**.

### Architecture

```
Internet
   │
   ▼
Application Load Balancer (port 80)
   │
   ├── /api/*  ──▶  ECS Flask Service  (Fargate, port 8000)  ──▶ MongoDB Atlas
   │
   └── /*      ──▶  ECS Node Service   (Fargate, port 3000)
```

### Terraform Files

| File | Purpose |
|---|---|
| `ecr.tf` | Two ECR repos (flask-backend, express-frontend) with scan\_on\_push and lifecycle policy |
| `vpc.tf` | VPC 172.20.0.0/16, two public subnets across ap-south-1a and ap-south-1b (ALB needs 2 AZs) |
| `security-group.tf` | alb\_sg: port 80 from internet; ecs\_sg: ports 3000 and 8000 from ALB only |
| `alb.tf` | ALB, target groups for Flask (8000) and Node (3000), listener rule routing /api/* to Flask |
| `ecs.tf` | Fargate task definitions with env vars (MONGO\_URI, BACKEND\_URL), CloudWatch logging, ECS services |
| `iam.tf` | ecsTaskExecutionRole — lets Fargate pull ECR images and write logs to CloudWatch |
| `main.tf` | ECS cluster and CloudWatch log groups |
| `variables.tf` | region, aws\_account\_id, image tags |
| `outputs.tf` | ECR URLs, ALB DNS name, app endpoints |

### Step 1 — Provision Infrastructure

```bash
cd infra/part3-ecs

terraform init
terraform fmt && terraform validate
terraform plan
terraform apply
terraform output   # Note the ALB DNS name and ECR URLs
```

### Step 2 — Build & Push Docker Images

> ⚠️ Mac M1/M2 users must use `--platform linux/amd64` — ECS Fargate runs on x86\_64. Without this flag the task fails with: *image Manifest does not contain descriptor matching platform linux/amd64*

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin \
  <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

# Build and push Flask backend (port 8000)
cd backend
docker buildx build \
  --platform linux/amd64 \
  --push \
  -t <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest .

# Build and push Express frontend (port 3000)
cd ../frontend
docker buildx build \
  --platform linux/amd64 \
  --push \
  -t <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/express-frontend:latest .
```

### Step 3 — Deploy ECS Services

```bash
# Force Flask service to pull new image
aws ecs update-service \
  --cluster app-cluster \
  --service flask-service \
  --force-new-deployment \
  --region ap-south-1

# Force Express service to pull new image
aws ecs update-service \
  --cluster app-cluster \
  --service node-service \
  --force-new-deployment \
  --region ap-south-1
```

### Step 4 — Monitor Deployment

```bash
# Watch until Running == Desired == 1 for both services
aws ecs describe-services \
  --cluster app-cluster \
  --services flask-service node-service \
  --region ap-south-1 \
  --query 'services[*].{Name:serviceName, Running:runningCount, Desired:desiredCount}'

# Stream Flask logs
aws logs tail /ecs/flask-backend --region ap-south-1 --since 5m --format short

# Stream Express logs
aws logs tail /ecs/express-frontend --region ap-south-1 --since 5m --format short
```

### Step 5 — Verify

```bash
# Get ALB DNS
aws elbv2 describe-load-balancers \
  --names app-alb \
  --region ap-south-1 \
  --query 'LoadBalancers[0].DNSName'

# Test Express frontend (port 3000 via ALB)
curl http://<ALB-DNS>/

# Test Flask backend (port 8000 via ALB)
curl -X POST http://<ALB-DNS>/api/submit \
  -H 'Content-Type: application/json' \
  -d '{"name": "Pankaj", "email": "pankaj@test.com"}'
# Expected: {"message": "Data submitted successfully"}
```

---

## 🐛 Common Issues & Fixes

| Issue | Cause | Fix |
|---|---|---|
| `CannotPullContainerError` | Image not pushed to ECR | Run `docker buildx build --push` |
| `platform linux/amd64` mismatch | Mac M1 builds arm64 by default | Add `--platform linux/amd64` to buildx |
| Health check failing (404) | Flask missing `GET /` route | Add `@app.route('/')` returning HTTP 200 |
| Exit code 137 (OOM kill) | 256MB too low for Flask + pymongo | Increase task memory to 1024MB |
| `MONGO_URI` is None | Env var not set in ECS task definition | Add `environment` block in `ecs.tf` |
| Express cannot reach Flask | `BACKEND_URL=127.0.0.1` — localhost unreachable in Fargate | Set `BACKEND_URL=http://${aws_lb.app.dns_name}/api` |
| Log group not found | CloudWatch log group not created before task start | Run `aws logs create-log-group` or add to Terraform |

---

## 🚀 Key Features

* Infrastructure provisioning using Terraform across three architectures
* Automated EC2 setup using Cloud-Init user data scripts
* Secure networking with custom AWS VPC and Security Groups
* Containerised microservices deployed on ECS Fargate
* Path-based ALB routing — `/api/*` to Flask, `/*` to Express
* CloudWatch logging for both containers
* MongoDB Atlas as cloud-managed database

---

## 📌 Learning Outcomes

* Hands-on experience with Terraform IaC on AWS
* Understanding EC2, VPC, ECS, ECR, ALB, IAM components
* Building and pushing Docker images to private ECR
* Debugging ECS Fargate task failures using CloudWatch
* Managing multi-service deployments with path-based routing

---

## 📬 Author

**Pankaj Gururani**