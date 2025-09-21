variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true

}

variable "db_db" {
  type = string
}

variable "docker_username" {
  type = string
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}