variable "aws_region" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "subnet1_cidr" {
  type = string
}
variable "rt_cidr" {
  type = string
}
variable "key_pair" {
  type = string
}
variable "ami_image_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "ssh_allowed_host" {
  type = string
}
variable "pcc_domain_name" {
  type = string
}
variable "pcc_password" {
  type = string
}
variable "pcc_username" {
  type = string
}