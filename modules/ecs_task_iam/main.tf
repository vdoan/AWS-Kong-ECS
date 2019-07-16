# IAM roles for KONG ECS Task
resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "1"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  
  statement {
    sid = "2"
    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_parameter_name_prefix}/*",
    ]
  }
}
resource "aws_iam_policy" "ecs_task_policy" {
  name      = "ecs_task_role_policy"
  path      = "/"
  policy    = "${data.aws_iam_policy_document.ecs_task_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = "${aws_iam_role.ecs_task.name}"
  policy_arn = "${aws_iam_policy.ecs_task_policy.arn}"
}

resource "aws_iam_policy_attachment" "ecs_services_policy" {
    name = "ecs_services_policy-attachment"
    roles = ["${aws_iam_role.ecs_task.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy" {
    name = "ecs_task_execution_role_policy-attachment"
    roles = ["${aws_iam_role.ecs_task.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}