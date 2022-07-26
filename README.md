# Workload Protection on ARM

This repository contains terraform files to deploy a k3s cluster on an ARM64 instance with a defender agent on AWS and GCP. This is intended for demonstration purposes of Prisma Cloud's support of the ARM architecture. 

## Specs 
**AWS**
- VPC (1)
- Security Group (1)
- Subnet (1)
- Internet Gateway (1)
- Default Route Table (1)
- EC2 Instance (1)
- EC2 Launch Template (1)

**GCP**
- GCE Instance (1)

## Prerequisites
- Prisma Cloud Compute Edition (version 22.06 or later) or Prisma Cloud Enterprise Edition
- Access Keys (Enterprise Edition) or User Credentials (Compute Edition)
- AWS Account / GCP Account 
- Terraform Cloud Account

## How to Use 
1. Clone this repository. 
```
git clone https://github.com/amckenzie7/Workload-Protection-on-ARM.git
cd Workload-Protection-on-ARM
```
2. Change directory to the folder of the cloud provider you'll be using. 
```
cd aws
```
**or** 
```
cd gcp
```
3. Open the `terraform.auto.tfvars` file and replace the following variables. Do not include the braces. 

**AWS**
```
key_pair         = "[KEY_PAIR]" # EC2 Instance Key Pair
pcc_username     = "[COMPUTE_USER]" # Access ID for SaaS users
pcc_password     = "[COMPUTE_PASS]" # Secret Key for SaaS users
pcc_domain_name  = "[CONSOLE_DOMAIN_NAME]" # Domain name loacted in Compute > Manage > System > Utilities Path to Console for SaaS Users
```
**GCP**
```
project_id       = "[PROJECT_ID]" # GCP Project ID
pcc_username     = "[COMPUTE_USER]" # Access ID for SaaS users
pcc_password     = "[COMPUTE_PASS]" # Secret Key for SaaS users
pcc_domain_name  = "[CONSOLE_DOMAIN_NAME]" # Domain name loacted in Compute > Manage > System > Utilities Path to Console for SaaS Users
```
4. Navigate to the `provider.tf` file and modify the terrraform block to organization and workspace this project will be executed within Terraform Cloud. 
```
terraform {
  cloud {
    organization = "[ORGANIZATION_NAME]"

    workspaces {
      name = "[WORKSPACE_NAME]"
    }
  }
}
```
5. Initialize the project
```
terraform init
```
6. Validate the project 
```
terraform validate
```
7. Apply the project
```
terraform apply
```

## Future Enhancements 
- Custom networking resources for GCP

## Addtional Resources
- [Primsa Cloud Compute System Requirements](https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/install/system_requirements)
- [Prisma Cloud + AWS ARM Announcement Blog](https://www.paloaltonetworks.com/blog/prisma-cloud/aws-graviton/)
- [Prisma Cloud + GCP ARM Announcement Blog](https://www.paloaltonetworks.com/blog/prisma-cloud/supports-arm-workloads-on-google-cloud-and-gke/)
- [AWS Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GCP Terraform Provider Docuementation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)