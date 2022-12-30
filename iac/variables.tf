variable "prefix" {
  type        = string
  description = "The prefix used for all resources in this example. (A bunch of alphanumeric characters.)"
}

variable "location" {
  type        = string
  description = "The Azure location where all resources in this example should be created"
}

variable "rgname" {
  type        = string
  description = "Azure resource group name"
}

variable "dbadmin" {
  type        = string
}

variable "dbadminpass" {
  type        = string
}