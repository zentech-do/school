provider "aws" {
  region = "us-west-2"
}

# Module VPC
module "vpc" {
  source = "./modules/vpc"  # Đảm bảo đường dẫn đến module là chính xác

  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "MyVPC"  # Thêm tên cho VPC nếu cần
}

# Module Subnets
module "subnets" {
  source = "./modules/subnets"

  vpc_id              = module.vpc.vpc_id
  public_subnet_cidrs = var.public_subnet
  private_subnet_cidrs = var.private_subnet
  availability_zones   = var.availability_zones
}

# Module Security Groups
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  local_ip = var.local_ip
}

# Module Routables
module "routables" {
  source = "./modules/routables"

  vpc_id          = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}

# Module EC2 Instances
module "ec2_instances" {
  source = "./modules/ec2_instances"

  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  public_ami_id     = var.public_ami_id
  private_ami_id    = var.private_ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  public_sg_id      = module.security_groups.public_sg_id
  private_sg_id     = module.security_groups.private_sg_id
}


