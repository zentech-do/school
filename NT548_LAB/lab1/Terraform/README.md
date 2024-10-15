# Terraform Project for AWS Infrastructure
This project provides a modular setup for creating a complete AWS infrastructure using Terraform. The structure includes separate modules for VPC, subnets, route tables, security groups, and EC2 instances. Each module is designed for flexibility and reusability.

## Project Structure
```{.no-copy}
Terraform/
├── main.tf                  # Main configuration that orchestrates the modules
├── modules/
│   ├── ec2_instances/        # Module to create EC2 instances
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── routables/            # Module for NAT Gateway, Route Tables, and Associations
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── security_groups/       # Module for Security Groups
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── subnets/               # Module for Public and Private Subnets
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc/                   # Module for VPC creation
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf               # Outputs for resources created by the modules
├── variables.tf             # Input variables for the main module
└── README.md                # Project documentation
README.md                # Project documentation
```
## Prerequisites
Before using this Terraform configuration, ensure you have the following:

* Terraform installed on your local machine. You can download it here.
* AWS CLI installed and configured with your credentials. Refer to AWS CLI documentation for help.

## Usage
### Step 1: Initialize the Terraform environment
Before applying the configuration, initialize your Terraform environment by running the following command in the project directory:
```
terraform init
```
This will download all required provider plugins and modules.

### Step 2: Define your variables
Create a terraform.tfvars file to define input variables required by the modules. Below is an example of what your terraform.tfvars file could look like:
```
# CIDR block for the VPC
vpc_cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block, e.g., "192.168.0.0/16"

# List of private subnet CIDR blocks
private_subnet = [
  "10.0.1.0/24",  # Replace with your private subnet CIDR, e.g., "192.168.1.0/24"
  "10.0.2.0/24"   # Add additional private subnets as needed
]

# List of public subnet CIDR blocks
public_subnet = [
  "10.0.3.0/24",  # Replace with your public subnet CIDR, e.g., "192.168.3.0/24"
  "10.0.4.0/24"   # Add additional public subnets as needed
]

# List of availability zones for the subnets
availability_zones = [
  "us-west-2a",  # Replace with your desired availability zones, e.g., "us-east-1a"
  "us-west-2b"   # Add additional availability zones as needed
]

# Number of public instances to create
public_instance_count = 1  # Change to the number of public instances you want

# Number of private instances to create
private_instance_count = 1  # Change to the number of private instances you want

# AMI ID for public instances
public_ami_id = "ami-04dd23e62ed049936"  # Replace with a suitable AMI ID for your public instances

# AMI ID for private instances
private_ami_id = "ami-04dd23e62ed049936"  # Replace with a suitable AMI ID for your private instances

# Type of EC2 instance
instance_type = "t2.micro"  # Change to your preferred instance type, e.g., "t2.medium"

# Key pair name for SSH access to instances
key_name = "demo"  # Replace with the name of your SSH key pair

# ADD YOUR LOCAL IP ADDRESS
local_ip = "0.0.0.0"  # Change to your actual local IP address, e.g., "192.168.1.100"
```

### Step 3: Plan the infrastructure
Generate an execution plan by running:

```
terraform plan
```
This will show you the actions Terraform will take to set up your infrastructure.

### Step 4: Apply the configuration
To apply the changes and provision the AWS resources, run:

```
terraform apply
```

Type yes when prompted to confirm.

### Step 5: Access the created resources
Once the infrastructure has been created, you can view the outputs like VPC ID, subnet IDs, and EC2 instance details by running:

```
terraform output
```
These outputs will provide important information such as EC2 public IPs for SSH access, subnet IDs, and more.

### Step 6: Clean up
To destroy all resources created by this Terraform configuration, run:

```
terraform destroy
```
This will remove all the resources from your AWS account.

## Modules
### VPC Module (modules/vpc)
This module handles the creation of a custom VPC with specified CIDR blocks.

### Subnets Module (modules/subnets)
This module creates both public and private subnets within the VPC.

### Routables Module (modules/routables)
This module configures the internet gateway, NAT gateway, and associated route tables for public and private subnets.

### Security Groups Module (modules/security_groups)
This module sets up security groups with specific ingress and egress rules for public and private EC2 instances.

### EC2 Instances Module (modules/ec2_instances)
This module provisions EC2 instances in both public and private subnets and attaches the appropriate security groups.





