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
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name     = "ecs_instance_role_policy"
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameters"
      ],
      "Resource": "arn:aws:ssm:$${account_id}:parameter/$${ssm_parameter_name_prefix}/*"
    }
  ]
}
EOF
  vars {
    account_id                  = "${var.account_id}"
    ssm_parameter_name_prefix   = "${var.ssm_parameter_name_prefix}"
  }
  role     = "${aws_iam_role.ecs_container_instance.id}"
}

# Instance profile for this role - to be attached to ASG instances
resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-container-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs_container_instance.name}"
}
