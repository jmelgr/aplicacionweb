variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "ec2_ami" {
  description = "AMI ID para las EC2"
  type        = string
}

variable "ec2_key_name" {
  description = "Nombre del key pair para EC2"
  type        = string
}
