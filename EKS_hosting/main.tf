####VPC####
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks_vpc"
  cidr = var.eks_vpc_cidr

  #   azs            = ["us-east-1a"] //data.aws_availability_zones.azs
  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames   = true //whether instances launched in the VPC receive public DNS hostnames that correspond to their public IP addresses.
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = 1
  }
}

###EKS####
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
#   version = "~> 19.0"

  cluster_name    = "myeks"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  #   control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.micro"]
      #   capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}