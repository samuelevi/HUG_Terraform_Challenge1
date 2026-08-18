HUG Lagos/Ibadan Terraform Challenge — Week One

Project: Deploy a Basic Web Server on AWS Using Terraform

This project provisions a complete, isolated network on AWS and launches an EC2 instance running Nginx, entirely through Terraform (Infrastructure as Code). The instance serves a simple webpage displaying the deployer's name and the challenge title.

Architecture Overview

This configuration creates:

- A custom VPC (`10.0.0.0/16`)
- A public subnet (`10.0.1.0/24`) inside the VPC
- An Internet Gateway attached to the VPC
- A Route Table with a `0.0.0.0/0` route pointing to the Internet Gateway, associated with the public subnet
- A Security Group allowing inbound SSH (port 22) and HTTP (port 80), with all outbound traffic allowed
- An EC2 instance (Ubuntu 22.04, `t3.micro`) launched in the public subnet

VPC → Subnet → Internet Gateway → Route Table → Route Table Association → Security Group → EC2 Instance.

Prerequisites

Before deploying, make sure you have:

- Terraform installed (`terraform -version` to check)
- An AWS account
- AWS CLI installed and configured with credentials that have permission to create VPC, EC2, and networking resources:
   bash
  aws configure


Project Structure
```
hug-terraform-webserver/
├── provider.tf # Terraform + AWS provider configuration
├── variables.tf # Input variable declarations
├── terraform.tfvars # Variable value assignments
├── main.tf # All infrastructure resources
├── outputs.tf # Post-apply output values
└── README.md
```
Deployment Instructions

1. Clone this repository and navigate into the project folder:

   bash
   git clone <your-repo-url>
   cd hug-terraform-webserver
   

2. Initialize Terraform — downloads the AWS provider plugin:

   bash
   terraform init
   

3. Review the execution plan — shows exactly what will be created, with no changes made yet:

   bash
   terraform plan
   

   Confirm the summary line reads `Plan: 7 to add, 0 to change, 0 to destroy.`

4. Apply the configuration — creates the actual AWS resources:

   bash
   terraform apply
   

   Type `yes` when prompted to confirm. EC2 instance creation typically takes 30–90 seconds.

5. Note the outputs — once complete, Terraform prints:

   
   instance_public_dns = "..."
   instance_public_ip  = "..."
   

6. Wait 1–2 minutes after apply completes, to allow the `user_data` boot script time to install and start Nginx.

7. Visit the webpage in a browser:
   
   http://<instance_public_ip>
   
   You should see the deployer's name and "HUG Lagos/Ibadan Terraform Challenge" displayed.

Outputs

Name                   Description

instance_public_ip`  - Public IP address of the EC2 instance 
instance_public_dns` - Public DNS name of the EC2 instance   


Cleanup

To avoid ongoing AWS charges, destroy all resources created by this project once you're done with it:

bash
terraform destroy


Notes

- t3.micro is used instead of t2.micro because Free Tier eligibility depends on AWS account age — newer accounts are eligible for t3.micro free tier hours, not t2.micro.
- The AMI is looked up dynamically via a data "aws_ami" block rather than hardcoded, so the configuration stays valid even as Canonical publishes newer Ubuntu 22.04 images.
