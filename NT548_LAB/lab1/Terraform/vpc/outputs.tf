# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

# Output the Private Subnet IDs
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}

# Output the Public Subnet IDs
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

# Output the Public EC2 Instance IDs
output "public_instance_ids" {
  description = "The IDs of the public EC2 instances"
  value       = [for instance in aws_instance.public_instance : instance.id]
}

# Output the Private EC2 Instance IDs
output "private_instance_ids" {
  description = "The IDs of the private EC2 instances"
  value       = [for instance in aws_instance.private_instance : instance.id]
}

# Output the Public EC2 Instance Public IPs
output "public_instance_public_ips" {
  description = "The public IP addresses of the public EC2 instances"
  value       = [for instance in aws_instance.public_instance : instance.public_ip]
}

# Output the Private EC2 Instance Private IPs
output "private_instance_private_ips" {
  description = "The private IP addresses of the private EC2 instances"
  value       = [for instance in aws_instance.private_instance : instance.private_ip]
}

# Output the Security Group IDs for Public EC2
output "public_security_group_id" {
  description = "The security group ID for the public EC2 instances"
  value       = aws_security_group.public_sg.id
}

# Output the Security Group IDs for Private EC2
output "private_security_group_id" {
  description = "The security group ID for the private EC2 instances"
  value       = aws_security_group.private_sg.id
}

# Output the Internet Gateway ID
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.ig.id
}

# Output the NAT Gateway ID
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.public.id
}

# Output the Public Route Table ID
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

# Output the Private Route Table ID
output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}
