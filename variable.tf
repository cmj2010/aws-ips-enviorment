variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr1" {
  default = "10.0.1.0/24"
}

variable "availability_zone1" {
  default = "cn-northwest-1a"
}

variable "private_subnet_cidr1" {
  default = "10.0.11.0/24"
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instance"
  default     = ""
}


variable "fgt_byol_license" {
  default = ""
}

variable "user_data_fgt" {
  default = ""
}

variable "user_data_linux" {
  default = ""
}

variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "terraform"
}

variable "tag_name_unique" {
  description = "Provide a unique tag prefix value that will be used in the name tag for each modules resources"
  default     = "automatically gathered by terraform modules"
}

