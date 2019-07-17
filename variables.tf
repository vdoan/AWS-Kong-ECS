variable "app_name" {
  default = "Kong"
}
variable "region" {
  default = "ap-southeast-2"
}
variable "ssh_key_name" {
  default = "kong_ec2_key"
}
 
 # ECS
variable "ecs_cluster_instance_type" {
  #default = "t2.micro"
  default = "m5.xlarge"
}
variable "app_image" {
  #default = "rdkls/kong_ssm:latest"
  default = "mdesouky/kong:latest"
}
variable "ecs_service_desired_count" {
  default = 1
}
variable "container_memory_reservation" {
  default = 64
}

# DB
variable "db_name" {
  default = "kong"
}
variable "db_username" {
  default = "kong"
}
variable "db_password" {
  default = "blablabla"
}
variable "db_engine" {
  default = "postgres"
}
variable "db_engine_version" {
  default = "9.5"
}
variable "db_parameter_group_family" {
  default = "postgres9.5"
}
variable "db_instance_class" {
  default = "db.t2.micro"
}
variable "bastion_instance_class" {
  default = "t2.micro"
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

# Kong
variable "kong_port_admin" {
  default = "8001"
}
variable "kong_port_http" {
  default = 8000
}
variable "kong_port_https" {
  default = 8443
}
