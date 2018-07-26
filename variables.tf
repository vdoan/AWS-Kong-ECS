variable "app_name" {
  default = "Kong"
}
variable "region" {
  default = "ap-southeast-2"
}
variable "ssh_key_name" {
  default = "jk_sydney"
}

# SSM
variable "ssm_parameter_name_prefix" {
  description = "prefix (like path) under which to store SSM parameters"
  default = "/dev/kong"
}
locals {
  ssm_parameter_name_db_username = "${var.ssm_parameter_name_prefix}/db_username"
  ssm_parameter_name_db_password = "${var.ssm_parameter_name_prefix}/db_password"
  ssm_parameter_name_db_engine = "${var.ssm_parameter_name_prefix}/db_engine"
  ssm_parameter_name_db_name = "${var.ssm_parameter_name_prefix}/db_name"
}
 
 # ECS
variable "ecs_cluster_instance_type" {
  default = "t2.micro"
}
variable "app_image" {
  default = "kong:0.14.0-alpine"
}
variable "ecs_service_desired_count" {
  default = 1
}
variable "container_memory_reservation" {
  default = 128
}

# DB
variable "db_username" {
  default = "postgres"
}
variable "db_password" {
  default="blablabla"
}
variable "db_name" {
  default="kong"
}
variable "db_engine" {
  default = "postgres"
}
variable "db_engine_version" {
  default = "9.5"
}
variable "db_instance_class" {
  default = "db.t2.micro"
}
variable "db_port" {
  default = 5432
}
variable "db_maintenance_window" {
  default = "Mon:00:00-Mon:03:00"
}
variable "db_backup_window" {
  default = "03:00-06:00"
}
variable "db_allocated_storage_gb" {
  default = 5
}
