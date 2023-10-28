####VPC####
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.jenkins_vpc_cidr

  azs            = ["us-east-1a"] //data.aws_availability_zones.azs
  public_subnets = var.public_subnets

  enable_dns_hostnames = true //whether instances launched in the VPC receive public DNS hostnames that correspond to their public IP addresses.

  tags = {
    project     = "jenkin_instance"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    proj = "jenkin"
  }
}

#### SG #####
module "jenkin_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkin_server_sg"
  description = "Security group Jenkin server"
  vpc_id      = module.vpc.vpc_id

  # ingress_cidr_blocks      = ["10.10.0.0/16"]
  # ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

###ec2#####

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-instance"

  instance_type          = var.instance_type
  # key_name               = "jenkin_server"
  monitoring             = true
  vpc_security_group_ids = [module.jenkin_server_sg.security_group_id]

  # vpc_security_group_ids      = [module.jenkin_server_sg.this_security_group_id] 
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins_install.sh")
  availability_zone           = "us-east-1a"

  tags = {
    instance    = "jenkins"
    Terraform   = "true"
    Environment = "dev"
  }
}