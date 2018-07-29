# VPC
module "vpc" {
  source                    = "modules/vpc"

  name                      = "${var.app_name} VPC"
  cidr                      = "10.0.0.0/16"
  map_public_ip_on_launch   = false

  azs                       = "${data.aws_availability_zones.available.names}"
  private_subnets           = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets            = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway        = true
  single_nat_gateway        = false
  one_nat_gateway_per_az    = true
  enable_vpn_gateway        = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

