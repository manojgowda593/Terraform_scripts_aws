# ECS_Prod_Script

This folder contains Terraform scripts to provision a **production-grade ECS Fargate setup on AWS**.  
It is part of the [`terraform_script`](../..) repository, which is intended to store reusable **production-ready Terraform IaC modules**.

---

## 📌 Overview

The `ECS_Prod_Script` provisions a **highly available and secure infrastructure** with the following components:

- **Networking (VPC)**  
  - 1 VPC spanning 2 Availability Zones (AZs).  
  - 2 Public Subnets (for ECS tasks, ALB).  
  - 2 Private Subnets (for RDS).  
  - Secure traffic flow — requests only enter through the **ALB → ECS Security Group**.  

- **ECS (Elastic Container Service - Fargate)**  
  - ECS Cluster running application tasks in **Fargate**.  
  - ECS Service connected to **Application Load Balancer (ALB)**.  
  - ECS Tasks use **AWS Secrets Manager** for injecting environment variables (DB credentials, app secrets, etc.).  
  - Enabled **CloudWatch Logs** for container log monitoring.  

- **RDS (Relational Database Service)**  
  - Multi-AZ RDS instance deployed in private subnets.  
  - Not publicly accessible, reachable only from ECS via **security groups**.  
  - Credentials securely managed via **AWS Secrets Manager**.  

- **Application Load Balancer (ALB)**  
  - Public ALB handling all incoming traffic.  
  - ALB forwards requests only to ECS tasks.  
  - Health checks for containerized apps to ensure high availability.  

- **IAM Roles & Policies**  
  - IAM Role for ECS tasks to fetch secrets from AWS Secrets Manager.  
  - Least-privilege access policies for ECS, RDS, and CloudWatch integration.  

- **Terraform Backend (S3)**  
  - Remote state management using **S3 backend** for consistent state across teams.  
  - (Optional) Can be extended with **DynamoDB for state locking** to avoid race conditions in collaborative environments.  

---

## 🏗️ Infrastructure Diagram (High-Level)





- **ALB**: Handles all external requests.  
- **ECS Tasks**: Run containerized applications on Fargate.  
- **RDS**: Private, secure database backend.  
- **S3 Backend**: Stores Terraform state remotely for consistency.  

---

## 🚀 Features

- **Production-ready** setup with secure VPC design.  
- **Secrets Manager integration** for sensitive configurations.  
- **Remote backend on S3** for reliable Terraform state management.  
- **End-to-End Monitoring** with CloudWatch.  
- **Scalable ECS service** behind an ALB.  
- **Cost-optimized** using Fargate (serverless containers).  

---

## 📂 Repo Structure

```bash
terraform_script/
│── ECS_Prod_Script/   # ECS + RDS + ALB setup (current folder)
│── EKS_Prod_Script/   # (future) Kubernetes production-level script
