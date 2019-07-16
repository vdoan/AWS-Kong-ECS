# IAM roles for ECS
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

  statement {
    sid = "3"
    actions = [
      "rds-db:connect",
    ]

    resources = [
      "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${var.dbi_resource_id}/${var.db_username}",
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