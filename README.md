# 🚀 AWS ECS CI/CD Project using Terraform & GitLab

This project automates the deployment of a containerized web application to Amazon ECS (Fargate) using Terraform and a GitLab CI/CD pipeline. The application is a simple Nginx web service containerized with Docker, and the pipeline automatically builds, pushes, and deploys it on ECS.

## 🧩 Project Structure
```text
ecs-terraform-gitlab/
│
├── app/                      # Sample containerized web app
│   ├── Dockerfile
│   └── index.html
│
├── terraform/                # Terraform Infrastructure-as-Code (IaC)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── (resources for ECS, VPC, Subnets, SG, ECR, etc.)
│
├── .gitlab-ci.yml            # GitLab CI/CD pipeline definition
└── README.md                 # Project documentation
```


## 🎯 Objective

The goal of this project is to automate ECS deployment with infrastructure and pipeline as code, demonstrating:

- Containerization with Docker

- Infrastructure as Code (IaC) with Terraform

- Continuous Integration & Deployment (CI/CD) using GitLab

- Automatic vertical scaling by changing ECS service size variables

- Centralized logging using AWS CloudWatch


| Category         | Tools Used      |
| ---------------- | --------------- |
| Cloud Provider   | AWS             |
| IaC              | Terraform       |
| CI/CD            | GitLab CI/CD    |
| Containerization | Docker          |
| Compute          | ECS Fargate     |
| Repository       | GitHub / GitLab |
| Logging          | AWS CloudWatch  |


## 🏗️ Infrastructure Overview

The Terraform configuration creates the following components:

| Resource                           | Description                                                           |
| ---------------------------------- | --------------------------------------------------------------------- |
| **VPC**                            | Custom VPC (`10.0.0.0/16`) with two public subnets                    |
| **Subnets**                        | Two public subnets across different AZs (`us-east-1a` & `us-east-1b`) |
| **Internet Gateway & Route Table** | Provides public internet access for ECS tasks                         |
| **Security Group**                 | Allows inbound HTTP (port 80)                                         |
| **ECR Repository**                 | Stores Docker images built by the CI/CD pipeline                      |
| **CloudWatch Log Group**           | Captures container logs from ECS                                      |
| **ECS Cluster**                    | Manages Fargate-based services                                        |
| **ECS Task Definition**            | Defines container CPU/memory and image                                |
| **ECS Service**                    | Deploys and maintains the running task in ECS                         |


## 🐳 Application (app/)

A minimal Nginx web app used for testing container deployment.

### Dockerfile
``` text
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```
### index.html
```text
<html>
  <body style="font-family: sans-serif; text-align: center;">
    <h2>ECS CI/CD Deployment Success!</h2>
  </body>
</html>
```

## ⚙️ Terraform Configuration (terraform/)

The Terraform scripts:

- Create all AWS resources (VPC, ECS, ECR, CloudWatch)

- Automatically read parameters (like ECR image URL and tag) from pipeline variables

## ⚙️ CI/CD Pipeline (.gitlab-ci.yml)
### Pipeline Stages
| Stage       | Description                                    |
| ----------- | ---------------------------------------------- |
| **build**   | Builds Docker image & pushes to AWS ECR        |
| **deploy**  | Runs Terraform to provision & deploy ECS       |
| **destroy** | Manually triggered Terraform destroy (cleanup) |


### Key automation features:

- Uses aws-cli for authentication and ECR creation

- Uses Terraform Docker image for IaC apply/destroy

- Pipeline variables dynamically set the image tag and scaling level

- Destroy job is manual to avoid accidental deletions

## Environment Variables (GitLab → Settings → CI/CD → Variables)
| Key                     | Description      | Example                      |
| ----------------------- | ---------------- | ---------------------------- |
| `AWS_ACCESS_KEY_ID`     | AWS access key   | `AKIA********`               |
| `AWS_SECRET_ACCESS_KEY` | AWS secret       | `********`                   |
| `AWS_ACCOUNT_ID`        | AWS account ID   | `123456789012`               |
| `AWS_REGION`            | AWS region       | `us-east-1`                  |
| `SERVICE_SIZE`          | ECS scaling size | `small` / `medium` / `large` |


## 🚀 Deployment Steps
### 1️⃣ Setup AWS S3 backend for Terraform state

The Terraform backend stores remote state:
```bash
terraform {
  backend "s3" {
    bucket         = "<BUCKET_NAME>"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Ensure the S3 bucket and DynamoDB table exist before first run:
```bash
aws s3 mb s3://<BUCKET_NAME> --region us-east-1
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2️⃣ Run GitLab Pipeline

Push code to main branch (pipeline triggers automatically). Or manually run pipeline → Build → Pipelines → Run Pipeline.

Stages:

- build: Builds Docker image and pushes to ECR

- deploy: Applies Terraform to deploy ECS

- Check ECS Cluster → Tasks → copy Public IP and test in browser:

```text
http://<PUBLIC_IP>
```

You should see:

### ECS CI/CD Deployment Success!

### 3️⃣ Destroy Infrastructure (Manual)

Trigger the destroy job from the GitLab pipeline UI:

```bash
terraform destroy -auto-approve
```
This removes all ECS resources (VPC, subnets, ECS, ECR, CloudWatch).

## 🔍 Outputs

After terraform apply, useful details are shown:
``` bash
Outputs:
  ecs_cluster_name        = "ecs_project-cluster"
  ecs_service_name        = "ecs_project-service"
  ecr_repository_url      = "123456789012.dkr.ecr.us-east-1.amazonaws.com/ecs_project"
  public_subnet_ids       = ["subnet-xxxx", "subnet-yyyy"]
  log_group_name          = "/ecs/ecs_project"
```

## 🧠 Useful AWS CLI Commands

Get the public IP of the running ECS task:
```bash
CLUSTER="ecs_project-cluster"
SERVICE="ecs_project-service"
REGION="us-east-1"

TASK_ARN=$(aws ecs list-tasks --region $REGION --cluster $CLUSTER --service-name $SERVICE --desired-status RUNNING --query 'taskArns[0]' --output text)
ENI_ID=$(aws ecs describe-tasks --region $REGION --cluster $CLUSTER --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
aws ec2 describe-network-interfaces --region $REGION --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Association.PublicIp' --output text
```

## 📘 Summary
| Feature                               | Implemented |
| ------------------------------------- | ----------- |
| Containerized app with Docker         | ✅           |
| Terraform-based AWS infrastructure    | ✅           |
| ECS Fargate deployment                | ✅           |
| GitLab CI/CD automation               | ✅           |
| CloudWatch logging                    | ✅           |
| Vertical scaling (small/medium/large) | ✅           |
| Automated ECR image builds            | ✅           |


## 👤 Author
**Andrew Ferdinandus** <br>
💻 Senior Linux / Systems Engineer <br>
📍 New Zealand <br>
🔗 [GitHub Profile](https://github.com/andrewferdinandus)  |  [LinkedIn](https://www.linkedin.com/in/andrew-ferdinandus/)


