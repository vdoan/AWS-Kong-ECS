resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "ecs.local"
  vpc = "${module.vpc.vpc_id}"
}

