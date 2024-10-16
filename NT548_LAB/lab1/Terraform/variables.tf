# variables.tf

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
}

variable "public_instance_count" {
  description = "Number of public instances to create"
  type        = number
}

variable "private_instance_count" {
  description = "Number of private instances to create"
  type        = number
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
  description = "Type of EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access to instances"
  type        = string
}

variable "local_ip" {
  description = "ADD YOUR LOCAL IP ADDRESS"
  type        = string
}
# Path to the private key used for SSH access
variable "private_key_path" {
  description = "The path to the private key used for SSH."
  type        = string
}
