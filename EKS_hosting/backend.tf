terraform {
  backend "s3" {
    bucket = "ec2-jenkins-tf"
    key    = "EKS_host/eks_terraform.tfstate"
    region = "us-east-1"
  }
}