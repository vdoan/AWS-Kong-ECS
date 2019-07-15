provider "aws" {
    region      = "${var.region}"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile                 = "default"
    
}
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
