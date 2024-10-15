output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "public_instance_ids" {
  value = module.ec2_instances.public_instance_ids
}

output "private_instance_ids" {
  value = module.ec2_instances.private_instance_ids
}