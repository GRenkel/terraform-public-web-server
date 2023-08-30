# Infrastructure as Code (IaC) with Terraform

This repository contains Terraform code to provision a simple AWS infrastructure. The infrastructure includes a VPC with public and private subnets, security groups, an EC2 instance running a basic web server, and associated resources.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS credentials (access key and secret key) configured.

## Usage

1. Clone this repository:

   ```
   git clone https://github.com/GRenkel/terraform-public-web-server.git
   cd terraform-public-web-server
   ```

2. Initialize Terraform:

   ```
   terraform init
   ```

3. Customize variables (optional):

   You can edit the `terraform.tfvars` file to adjust variables, or you can pass them as command-line arguments.

4. Plan the infrastructure:

   ```
   terraform plan
   ```

5. Deploy the infrastructure:

   ```
   terraform apply
   ```

6. Clean up:

   When you're done, destroy the resources:

   ```
   terraform destroy
   ```

## Description

This Terraform code provisions the following resources on AWS:

- VPC (`aws_vpc.app-vpc`): Creates a Virtual Private Cloud with a defined CIDR block.
- Internet Gateway (`aws_internet_gateway.app-igw`): Attaches an internet gateway to the VPC for public internet access.
- Egress Only Internet Gateway (`aws_egress_only_internet_gateway.egress-igw`): Enables IPv6 internet access for private subnets.
- Public Subnet (`aws_subnet.public-subnet-a`): Creates a public subnet with a CIDR block that can be specified as a variable.
- Private Subnet (`aws_subnet.private-subnet-a`): Creates a private subnet for backend services.
- Route Tables: Defines route tables for public and private subnets to control traffic flow.
- Security Groups (`aws_security_group.web-sg`): Sets up security groups to control inbound and outbound traffic.
- EC2 Instance (`aws_instance.web-app`): Launches an EC2 instance in the public subnet running a basic web server.

## Variables

- `pb-subnet-prefix`: CIDR block for the public subnet. Default is "10.0.0.0/24".

## Outputs

- `web-server-ip`: Public IP address of the deployed EC2 instance.

## Disclaimer

This Terraform code is meant for educational purposes and might not be suitable for production use without further customization and security considerations.
```
