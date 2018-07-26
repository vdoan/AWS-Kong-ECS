# IAM roles for ECS
resource "aws_iam_role" "ecs_task" {
  name               = "ecs-task-role"
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
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "ecs_task_role_policy" {
  template   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource": "arn:aws:ssm:$${region}:$${account_id}:parameter$${ssm_parameter_name_prefix}/*"
    }
  ]
}
EOF
  vars {
    account_id                  = "${var.account_id}"
    region                      = "${var.region}"
    ssm_parameter_name_prefix   = "${var.ssm_parameter_name_prefix}"
  }
}
resource "aws_iam_role_policy" "ecs_task" {
  name      = "ecs_task_role_policy"
  role      = "${aws_iam_role.ecs_task.id}"
  policy    = "${data.template_file.ecs_task_role_policy.rendered}"
}
