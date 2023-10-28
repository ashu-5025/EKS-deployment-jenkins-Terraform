terraform {
  backend "s3" {
    bucket = "ec2-jenkins-tf"
    key    = "jenkins_pr/terraform.tfstate"
    region = "us-east-1"
  }
}