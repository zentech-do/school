# Creates AWS EC2 instances in public subnets
resource "aws_instance" "public_instance" {
  count             = length(var.public_subnet_ids)
  ami               = var.public_ami_id  
  instance_type     = var.instance_type  
  key_name          = var.key_name  
  subnet_id         = var.public_subnet_ids[count.index] 
  vpc_security_group_ids = [var.public_sg_id]  
  associate_public_ip_address = true  

  tags = {
    Name = "Public-Instance-${count.index + 1}" 
  }
}

# Creates AWS EC2 instances in private subnets
resource "aws_instance" "private_instance" {
  count             = length(var.private_subnet_ids)
  ami               = var.private_ami_id  
  instance_type     = var.instance_type  
  key_name          = var.key_name  
  subnet_id         = var.private_subnet_ids[count.index]  
  vpc_security_group_ids = [var.private_sg_id] 

  tags = {
    Name = "Private-Instance-${count.index + 1}"  
  }
}
