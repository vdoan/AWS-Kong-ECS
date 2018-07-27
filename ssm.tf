# Set SSM Parameters
resource "aws_ssm_parameter" "db_username" {
  name    = "${local.ssm_parameter_name_db_username}"
  value   = "${var.db_username}"
  type    = "SecureString"
}
resource "aws_ssm_parameter" "db_password" {
  name    = "${local.ssm_parameter_name_db_password}"
  value   = "${var.db_password}"
  type    = "SecureString"
}
resource "aws_ssm_parameter" "db_engine" {
  name    = "${local.ssm_parameter_name_db_engine}"
  value   = "${var.db_engine}"
  type    = "SecureString"
}
resource "aws_ssm_parameter" "db_host" {
  name    = "${local.ssm_parameter_name_db_host}"
  value   = "${replace(module.rds.this_db_instance_endpoint, "/:.*/", "")}"
  type    = "SecureString"
}
