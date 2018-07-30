# ECS Service & Task Definition
locals {
  kong_dash_app_image         = "pgbi/kong-dashboard"
  kong_dash_app_name          = "kong-dash"
  kong_dash_port_http         = 8080
  kong_admin_api_service_url  = "http://${aws_service_discovery_service.kong.name}.${aws_service_discovery_private_dns_namespace.main.name}:${var.kong_port_admin}"
}

resource "aws_ecs_task_definition" "kong_dash" {
  family                = "${local.kong_dash_app_name}"
  network_mode          = "awsvpc"
  container_definitions = <<EOF
[
  {
    "name"              : "${local.kong_dash_app_name}",
    "container_name"    : "${local.kong_dash_app_name}",
    "image"             : "${local.kong_dash_app_image}",
    "memoryReservation" : ${var.container_memory_reservation},
    "command"           : [
      "start",
      "--kong-url",
      "${local.kong_admin_api_service_url}"
    ],
    "portMappings": [
      {
        "ContainerPort" : ${local.kong_dash_port_http},
        "Protocol"      : "tcp"
      }
    ]
  }
]
EOF
}
resource "aws_ecs_service" "kong_dash" {
  name                = "${local.kong_dash_app_name}"
  launch_type         = "EC2"
  cluster             = "${aws_ecs_cluster.main.id}"
  task_definition     = "${aws_ecs_task_definition.kong_dash.arn}"
  desired_count       = "${var.ecs_service_desired_count}"
  scheduling_strategy = "DAEMON"

  service_registries {
    registry_arn      = "${aws_service_discovery_service.kong_dash.arn}"
    container_name    = "${local.kong_dash_app_name}"
  }
  network_configuration {
    subnets             = ["${module.vpc.private_subnets}"]
    assign_public_ip    = false
    security_groups     = ["${aws_security_group.ecs_service_kong_dash.id}"]
  }
}
resource "aws_service_discovery_service" "kong_dash" {
  name = "${local.kong_dash_app_name}"
  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.main.id}"
    dns_records {
      ttl = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
resource "aws_security_group" "ecs_service_kong_dash" {
  name        = "${var.app_name}-ECS-SG-${local.kong_dash_app_name}"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress = {
    description       = "all from bastion"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_groups   = [
      "${aws_security_group.bastion.id}"
    ]
  }
  egress = {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags  = [
    {
      Name = "${var.app_name}-ECS-SG-kong-dash"
    }
  ]
}
