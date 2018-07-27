provider "aws" {
    region      = "${var.region}"
}
  
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

