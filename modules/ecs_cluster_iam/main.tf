# IAM roles for ECS
resource "aws_iam_role" "ecs_container_instance" {
  name               = "ecs-container-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
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
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask"
      ],
      "Resource": "*"
    },
		{
			"Effect": "Allow",
			"Action": [
				"ec2:CreateNetworkInterface",
				"ec2:DescribeNetworkInterfaces",
				"ec2:DetachNetworkInterface",
				"ec2:DeleteNetworkInterface",
				"ec2:AttachNetworkInterface",
				"ec2:DescribeInstances",
				"autoscaling:CompleteLifecycleAction"
			],
			"Resource": "*"
		}
  ]
}
EOF
  role     = "${aws_iam_role.ecs_container_instance.id}"
}

# Instance profile for this role - to be attached to ECS instances
resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-container-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs_container_instance.name}"
}

output "ecs_instance_profile_id" {
  value = "${aws_iam_instance_profile.ecs.id}"
}
