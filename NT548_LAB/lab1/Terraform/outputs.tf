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


output "public_route_table_id" {
  value = module.routables.public_route_table_id
}

output "private_route_table_id" {
  value = module.routables.private_route_table_id
}

output "ig_id" {
  value = module.routables.ig_id
}

output "nat_gateway_id" {
  value = module.routables.nat_gateway_id
}