variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default = ["us-west-2a", "us-west-2b"] 
}

variable "public_instance_count" {
  description = "Number of public instances to create"
  type        = number
  default     = 1
}

variable "private_instance_count" {
  description = "Number of private instances to create"
  type        = number
  default     = 1
}

variable "public_ami_id" {
  description = "AMI ID for public instances"
  type        = string
  default     = "ami-04dd23e62ed049936"  # Thay thế bằng AMI ID phù hợp
}

variable "private_ami_id" {
  description = "AMI ID for private instances"
  type        = string
  default     = "ami-04dd23e62ed049936"  # Thay thế bằng AMI ID phù hợp
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"  # Ví dụ về loại instance
}

variable "key_name" {
  description = "Key pair name for SSH access to instances"
  type        = string
  default = "demo"
}

variable "local_ip"{
  description = "ADD YOUR LOCAL IP ADDRESS"
  type = string
  default = "0.0.0.0"
}