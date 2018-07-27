# ECS Service & Task Definition
module "ecs_task_iam" {
  source                      = "modules/ecs_task_iam"
  account_id                  = "${data.aws_caller_identity.current.account_id}"
  region                      = "${var.region}"
  ssm_parameter_name_prefix   = "${var.ssm_parameter_name_prefix}"
}
resource "aws_ecs_task_definition" "main" {
  family        = "${var.app_name}"
  task_role_arn = "${module.ecs_task_iam.arn}"
  container_definitions = <<EOF
[
  {
    "name": "${var.app_name}",
    "container_name": "${var.app_name}",
    "image": "${var.app_image}",
    "memoryReservation": ${var.container_memory_reservation},
    "portMappings": [
      {
        "ContainerPort": ${var.kong_port_http},
        "HostPort": ${var.kong_port_http},
        "Protocol": "tcp"
      },
      {
        "ContainerPort": ${var.kong_port_https},
        "HostPort": ${var.kong_port_https},
        "Protocol": "tcp"
      },
      {
        "ContainerPort": ${var.kong_port_admin},
        "HostPort": ${var.kong_port_admin},
        "Protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name"  : "KONG_ADMIN_LISTEN",
        "value" : "0.0.0.0:${var.kong_port_admin}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_USERNAME",
        "value" : "${local.ssm_parameter_name_db_username}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_PASSWORD",
        "value" : "${local.ssm_parameter_name_db_password}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_ENGINE",
        "value" : "${local.ssm_parameter_name_db_engine}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_HOST",
        "value" : "${local.ssm_parameter_name_db_host}"
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

  load_balancer {
    target_group_arn  = "${aws_alb_target_group.main.id}"
    container_name    = "${var.app_name}"
    container_port    = "${var.kong_port_http}"
  }
  depends_on = [
    "aws_alb.main"
  ]
}
