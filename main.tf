provider "aws" {
    region      = "${var.region}"
}
  
data "aws_availability_zones" "available" {}

# VPC
module "vpc" {
  source = "modules/vpc"

  name = "${var.app_name} VPC"
  cidr = "10.0.0.0/16"

  azs             = "${data.aws_availability_zones.available.names}"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# SGs
module "ecs_sg" {
  source      = "modules/sg"
  name        = "${var.app_name}-ECS-SG"
  vpc_id      = "${module.vpc.vpc_id}"

  # todo elb only
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description = "ssh"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "http"
      protocol    = "tcp"
      from_port   = 8000
      to_port     = 8000
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "https"
      protocol    = "tcp"
      from_port   = 8443
      to_port     = 8443
      cidr_blocks = "0.0.0.0/0"
    }
    # TODO 8001 admin from bastion only
  ]
  gress_with_cidr_blocks = [
    {
      description = "all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # Can't just use proto=-1 since the module then opens all ports
  ingress_with_self = [
    {
      description = "kong inter-node comms, tcp"
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
    },
    {
      description = "kong inter-node comms, udp"
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
    }
  ]
}

# ECS Cluster
data "aws_ami" "ecs" {
  most_recent = true
  filter {
    name      = "owner-alias"
    values    = ["amazon"]
  }
  filter {
    name      = "name"
    values    = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}
module "ecs_cluster_iam" {
  source = "modules/ecs_cluster_iam"
}
data "template_file" "ecs_user_data" {
  template = <<EOF
#!/bin/bash
echo ECS_CLUSTER='${var.app_name}' > /etc/ecs/ecs.config
EOF
}
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}"
}
module "asg" {
  source = "modules/asg"

  name = "${var.app_name}-ECS-ASG"

  # Launch configuration
  lc_name = "${var.app_name}-ECS-LC"

  image_id        = "${data.aws_ami.ecs.id}"
  instance_type   = "${var.ecs_cluster_instance_type}"
  security_groups = ["${module.ecs_sg.this_security_group_id}"]
  key_name        = "${var.ssh_key_name}"

  # block devices - use defaults

  # Auto scaling group
  asg_name                  = "${var.app_name}-ECS-ASG"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  iam_instance_profile      = "${module.ecs_cluster_iam.ecs_instance_profile_id}"
  user_data                 = "${data.template_file.ecs_user_data.rendered}"
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "kong demo"
      propagate_at_launch = true
    },
  ]
}
output "ami_id" {
  value = "${data.aws_ami.ecs.id}"
}

# ECS Service & Task Definition
resource "aws_ecs_task_definition" "main" {
  family        = "${var.app_name}"
  container_definitions = <<EOF
[
  {
    "Name": "${var.app_name}",
    "Image": "${var.app_image}",
    "MemoryReservation": ${var.container_memory_reservation},
    "PortMappings": [
      {
        "ContainerPort": 8443,
        "Protocol": "tcp"
      },
      {
        "ContainerPort": 8000,
        "Protocol": "tcp"
      }
    ]
  }
]
EOF
}
resource "aws_ecs_service" "main" {
  name              = "${var.app_name}"
  launch_type       = "EC2"
  cluster           = "${aws_ecs_cluster.main.id}"
  task_definition   = "${aws_ecs_task_definition.main.arn}"
  desired_count     = "${var.ecs_service_desired_count}"
}
