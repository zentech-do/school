provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "./vpc"

  vpc_cidr_block    = "10.0.0.0/16"
  private_subnet    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet     = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zone = ["us-west-2a", "us-west-2b"]
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "public_instance_ids" {
  value = module.vpc.public_instance_ids
}

output "private_instance_ids" {
  value = module.vpc.private_instance_ids
}

output "public_instance_public_ips" {
  value = module.vpc.public_instance_public_ips
}

output "private_instance_private_ips" {
  value = module.vpc.private_instance_private_ips
}

output "public_security_group_id" {
  value = module.vpc.public_security_group_id
}

output "private_security_group_id" {
  value = module.vpc.private_security_group_id
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}
