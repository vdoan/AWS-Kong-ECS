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
variable "ssm_parameter_name_db_username" {
  default = "/dev/kong/db_username"
}
variable "ssm_parameter_name_db_password" {
  default = "/dev/kong/db_password"
}
variable "ssm_parameter_name_db_engine" {
  default = "/dev/kong/db_engine"
}
variable "ssm_parameter_name_db_name" {
  default = "/dev/kong/db_name"
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
