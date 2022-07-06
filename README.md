# Workload Protection on ARM

This repository contains terraform files to deploy a k3s cluster on an EC2 instance running on AWS Graviton2 (ARM64) and a defender agent within the cluster. The repo creates the following resources:

- VPC (1)
- Security Group (1)
- Subnets (1)
- Internet Gateway (1)
- Default Route Table (1)
- EC2 Instance (1)
- EC2 Launch Template (1)

## Prerequisites
- Prisma Cloud Compute Edition (version 22.06 or later) or Prisma Cloud Enterprise Edition
- Access Keys (SaaS) or User Credentials (Self-hosted)
- AWS Account 
- Terraform Cloud Account

## How to Use 
1. Clone this repository. 
`git clone https://github.com/amckenzie7/Workload-Protection-on-ARM.git`
`cd Workload-Protection-on-ARM`
2. Open the terraform.auto.tfvars file and replace the following variables. Do not include the braces. 
`
key_pair         = "[KEY_PAIR]"
pcc_username     = "[COMPUTE_USER]" # Access ID for SaaS users
pcc_password     = "[COMPUTE_PASS]" # Secret Key for SaaS users
pcc_domain_name  = "[CONSOLE_DOMAIN_NAME]" # Domain name loacted in Compute > Manage > System > Utilities Path to Console for SaaS Users`
3. Navigate to the provider.tf file and modify the terrraform block to organization and workspace this project will be executed within Terraform Cloud. 
`
terraform {
  cloud {
    organization = "[ORGANIZATION_NAME]"

    workspaces {
      name = "[WORKSPACE_NAME]"
    }
  }
}
`
4. Initialize the project
`terraform init`
5. Validate the project 
`terraform validate`
6. Apply the project
`terraform apply`
