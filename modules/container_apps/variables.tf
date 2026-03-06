

variable "app_environment_name" {
  type        = string
  description = "The azure container app environment"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group name to host the container apps."
}

variable "infrastructure_resource_group_name" {
  type        = string
  description = "The azure managed resource group for the container app environment."
}

variable "location" {
  type        = string
  description = "The location where to host the azure resources under this module."
}

variable "templates" {
  type = list(object({
    app_name     = string
    max_replicas = optional(number, 1)
    min_replicas = optional(number, 1)
    containers = list(object({
      name   = string
      cpu    = string
      memory = string
      image  = string
    }))
  }))
  description = "The container templates and images to be deployed as container apps."
}

variable "container_app_environment_id" {
  type        = string
  nullable    = true
  description = "An existing managed environment resource id."
  default     = null
}

variable "ip_security_restriction" {
  type = list(object({
    action   = string
    ip_range = string
  }))
  description = "The IP security restrictions for the container apps."
  default     = []
}

variable "iam_roles" {
  type = list(object({
    role_name = string
    scope     = string
  }))
  description = "IAM roles to assign to the container app instances."
  default     = []
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy."
  default     = null
  nullable    = true
}