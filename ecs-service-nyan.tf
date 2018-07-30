# ECS Service & Task Definition
locals {
  app_image     = "daviey/nyan-cat-web"
  app_name      = "nyan"
  port_http     = 80
}

resource "aws_ecs_task_definition" "nyan" {
  family        = "${local.app_name}"
  network_mode  = "awsvpc"
  container_definitions = <<EOF
[
  {
    "name": "${local.app_name}",
    "container_name": "${local.app_name}",
    "image": "${local.app_image}",
    "memoryReservation": ${var.container_memory_reservation},
    "portMappings": [
      {
        "ContainerPort": ${local.port_http},
        "Protocol": "tcp"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "nyan" {
  name              = "${local.app_name}"
  launch_type       = "EC2"
  cluster           = "${aws_ecs_cluster.main.id}"
  task_definition   = "${aws_ecs_task_definition.nyan.arn}"
  desired_count     = "${var.ecs_service_desired_count}"

  load_balancer {
    target_group_arn  = "${aws_alb_target_group.main.id}"
    container_name    = "${local.app_name}"
    container_port    = "${local.port_http}"
  }
  service_registries {
    registry_arn      = "${aws_service_discovery_service.nyan.arn}"
    container_name    = "${local.app_name}"
  }
  depends_on = [
    "aws_alb.main"
  ]
}
resource "aws_service_discovery_service" "nyan" {
  name = "nyan"
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
