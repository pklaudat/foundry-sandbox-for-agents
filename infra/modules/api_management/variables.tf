variable "name" {
  description = "azure api management resource name."
  type        = string
}

variable "location" {
  description = "location for the api mangement resource."
  type        = string
  default     = "eastus"
}

variable "publisher_name" {
  description = "the publisher name."
  type        = string
}

variable "publisher_email" {
  description = "the publisher email."
  type        = string
}

variable "sku" {
  description = "sku for the api management."
  type        = string
  default     = "Developer_1"
  validation {
    condition     = contains(["Developer_1", "BasicV2", "StandardV2"], var.sku)
    error_message = "allowed sku options are: developer, basicv2 and standardv2"
  }
}

variable "resource_group_name" {
  type        = string
  description = "resource group to host the api management related resources."
}

variable "additional_locations" {
  type    = list(string)
  default = []
}
