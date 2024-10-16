
output "public_instance_ids" {
  value       = aws_instance.public_instance[*].id
}

output "private_instance_ids" {
  value       = aws_instance.private_instance[*].id
}
output "public_instance_ip" {
  description = "The public IP of the public EC2 instance."
  value       = aws_instance.public_instance[0].public_ip
}

output "private_instance_ip" {
  description = "The private IP of the private EC2 instance."
  value       = aws_instance.private_instance[0].private_ip
}


