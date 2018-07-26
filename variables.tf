variable "app_name" {
  default = "Kong"
}
variable "region" {
  default = "ap-southeast-2"
}
 
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
variable "ssh_key_name" {
  default = "jk_sydney"
}
