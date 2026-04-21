# 🚀 FlaskP – Terraform AWS Deployment

This project demonstrates **Infrastructure as Code (IaC)** using Terraform to deploy a full-stack application on AWS.

The application consists of:

* **Frontend**: Node.js + Express
* **Backend**: Python + Flask
* **Database**: MongoDB

---

## 🧠 Project Objective

The goal of this project is to deploy the application in **three different architectures** using Terraform:

### 🔹 Part 1: Single EC2 Deployment

* Both Flask and Express run on a single EC2 instance
* Automated setup using user-data scripts
* Services exposed on different ports

  * Frontend → 3000
  * Backend → 8000

---

### 🔹 Part 2: Multi EC2 Deployment

* Separate EC2 instances for:

  * Flask backend
  * Express frontend
* Custom VPC, subnets, and security groups
* Secure communication between instances

---

### 🔹 Part 3: Containerized Deployment (ECS)

* Dockerized applications
* Images pushed to AWS ECR
* Deployment using ECS (Fargate)
* Application Load Balancer (ALB) for routing
* Fully scalable cloud-native architecture

---

## ☁️ Technologies Used

* Terraform
* AWS (EC2, VPC, ECS, ECR, ALB, IAM)
* Docker
* Node.js (Express)
* Python (Flask)
* MongoDB

---

## 📁 Project Structure

```text
FLASK-TERRAFORM/
├── backend/
├── frontend/
├── infra/
│   ├── part1-single-ec2/
│   ├── part2-multi-ec2/
│   ├── part3-ecs/
├── docker-compose.yaml
└── README.md
```

---

## 🚀 Key Features

* Infrastructure provisioning using Terraform
* Automated EC2 setup using user-data scripts
* Secure networking with AWS VPC and Security Groups
* Microservices deployment architecture
* Container-based deployment using ECS

---

## 📌 Learning Outcomes

* Hands-on experience with Terraform
* Understanding AWS infrastructure components
* Deploying scalable full-stack applications
* Managing cloud resources using Infrastructure as Code

---

## 📬 Author

Pankaj Gururani