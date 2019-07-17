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
  default = "m5.xlarge"
}
variable "app_image" {
  default = "mdesouky/kong:latest"
}
variable "ecs_service_desired_count" {
  default = 1
}
variable "container_memory_reservation" {
  default = 64
}
