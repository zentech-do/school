# Security Group for Public EC2 Instances
resource "aws_security_group" "public_sg" {
  vpc_id = var.vpc_id

  name        = "public-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.local_ip}/32"]
  }

  tags = {
    Name = "public-sg"
  }
}

# Security Group for Private EC2 Instances
resource "aws_security_group" "private_sg" {
  vpc_id = var.vpc_id

  name        = "private-sg"
  description = "Allow SSH from Public SG and all egress traffic"

  ingress {
    description = "Allow SSH from Public SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}


