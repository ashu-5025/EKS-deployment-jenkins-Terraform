variable "eks_vpc_cidr" {
  description = "CIDR value for your VPC"
  type        = string
}

variable "public_subnets" {
  description = "cidr value for public subnet"
  type        = list(string)
}

variable "private_subnets" {
  description = "cidr value for public subnet"
  type        = list(string)
}