# Create a custom VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name" = "custom" # Tag for identification
  }
}

# Create private subnets within the VPC
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet) # Create subnets based on the provided private subnet CIDR blocks

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)] # Distribute subnets across availability zones

  tags = {
    "Name" = "private-subnet" # Tag for identification
  }
}

# Create public subnets within the VPC
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet) # Create subnets based on the provided public subnet CIDR blocks

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)] # Distribute subnets across availability zones

  tags = {
    "Name" = "public-subnet" # Tag for identification
  }
}

# Create an Internet Gateway for public subnets
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "custom" # Tag for identification
  }
}

# Create a public route table to route traffic to the Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Allow all outbound traffic to the Internet
    gateway_id = aws_internet_gateway.ig.id # Route traffic through the Internet Gateway
  }

  tags = {
    "Name" = "public" # Tag for identification
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v } # Loop through public subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # Elastic IP for VPC
}

# Create a NAT Gateway for private subnets to route outbound traffic
resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id # Place NAT Gateway in the first public subnet

  tags = {
    Name = "Public NAT" # Tag for identification
  }
}

# Create a private route table to route private traffic through the NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Allow all outbound traffic
    gateway_id = aws_nat_gateway.public.id # Route traffic through the NAT Gateway
  }

  tags = {
    "Name" = "private" # Tag for identification
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v } # Loop through private subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Security Group for Public EC2 Instances allowing SSH and outbound traffic
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.vpc.id

  name        = "public-sg" # Name of the security group
  description = "Allow SSH traffic from a specific IP"

  ingress {
    description = "Allow SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR IP"] # Allow SSH from 
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols for outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to anywhere
  }

  tags = {
    Name = "public-sg" # Tag for identification
  }
}

# Security Group for Private EC2 Instances allowing traffic from public EC2 instances
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.vpc.id

  name        = "private-sg" # Name of the security group
  description = "Allow SSH traffic from public EC2 instance"

  ingress {
    description = "Allow SSH from public EC2 instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]  # Allow SSH traffic from the public security group
  }
  ingress {
    description = "Allow ICMP from public EC2 instance"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp" # Allow ping requests
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound protocols
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "private-sg" # Tag for identification
  }
}

# Launch Public EC2 Instances
resource "aws_instance" "public_instance" {
  count             = length(var.public_subnet) # Create instances based on the number of public subnets
  ami               = var.public_ami_id
  instance_type     = var.instance_type
  key_name = "demo"
  subnet_id = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.public_sg.id] # Associate the public security group
  associate_public_ip_address = true # Assign public IP address to instances
  

  tags = {
    Name = "Public-Instance-${count.index + 1}" # Tag for identification
  }
}

# Launch Private EC2 Instances
resource "aws_instance" "private_instance" {
  count             = length(var.private_subnet) # Create instances based on the number of private subnets
  ami               = var.private_ami_id
  instance_type     = var.instance_type
  key_name = "demo"
  subnet_id = aws_subnet.private_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.private_sg.id] # Associate the private security group
  tags = {
    Name = "Private-Instance-${count.index + 1}" # Tag for identification
  }
}