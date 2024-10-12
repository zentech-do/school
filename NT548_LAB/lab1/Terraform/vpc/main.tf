resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name" = "custom"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "custom"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "Public NAT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Security Group for Public EC2 Instances
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.vpc.id

  name        = "public-sg"
  description = "Allow SSH traffic from a specific IP"

  ingress {
    description = "Allow SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "public-sg"
  }
}

# Security Group for Private EC2 Instances
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.vpc.id

  name        = "private-sg"
  description = "Allow SSH traffic from public EC2 instance"

  ingress {
    description = "Allow SSH from public EC2 instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]  
  }
  ingress {
    description = "Allow ICMP from public EC2 instance"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "private-sg"
  }
}

# Attach Network Interface to Public EC2 Instance
resource "aws_instance" "public_instance" {
  count             = length(var.public_subnet)
  ami               = var.public_ami_id
  instance_type     = var.instance_type
  key_name = "demo"
  subnet_id = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  

  tags = {
    Name = "Public-Instance-${count.index + 1}"
  }
}

# Attach Network Interface to Private EC2 Instance
resource "aws_instance" "private_instance" {
  count             = length(var.private_subnet)
  ami               = var.private_ami_id
  instance_type     = var.instance_type
  key_name = "demo"
  subnet_id = aws_subnet.private_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "Private-Instance-${count.index + 1}"
  }
}


