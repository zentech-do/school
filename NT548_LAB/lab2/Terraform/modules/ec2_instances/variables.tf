variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_ami_id" {
  description = "AMI ID for public instances"
  type        = string
}

variable "private_ami_id" {
  description = "AMI ID for private instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair for SSH access"
  type        = string
}

variable "public_sg_id" {
  description = "Security group ID for public instances"
  type        = string
}

variable "private_sg_id" {
  description = "Security group ID for private instances"
  type        = string
}
