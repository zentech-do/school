# terraform.tfvars

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
