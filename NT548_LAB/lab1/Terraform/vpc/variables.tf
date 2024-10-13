variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  type    = list(string)
}

variable "public_subnet" {
  type    = list(string)
}

variable "availability_zone" {
  type    = list(string)
}
variable "public_instance_count" {
  type    = number
  default = 1
}

variable "private_instance_count" {
  type    = number
  default = 1
}

variable "public_ami_id" {
  type = string
  default = "ami-04dd23e62ed049936"
}

variable "private_ami_id" {
  type = string
  default = "ami-04dd23e62ed049936"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"  
}
