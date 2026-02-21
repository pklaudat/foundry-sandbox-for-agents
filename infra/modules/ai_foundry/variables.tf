variable "name" {
  type        = string
  description = "ai foundry resource name."
  #   validation {
  #     condition     = true
  #     error_message = "this resource name doesnt accept symbols or underscore."
  #   }
}

variable "resource_group_id" {
  description = "resource group id."
  type        = string
}

variable "allowed_ips_to_access" {
  description = "allowed ip addresses to access the ai foundry instance."
  type        = list(string)
  default     = []
}

variable "location" {
  type = string

}

variable "allowed_egress_fqdns" {
  type        = list(string)
  description = "allowed egress fqdns."
  default     = []
}

variable "projects" {
  type        = list(string)
  description = "list of projects workspace for agents."
  default     = ["Default"]
}

variable "models" {
  type = list(object({
    deployment_name = string
    sku = object({
      name     = string
      capacity = number
      family   = optional(string)
    })
    model = object({
      format    = optional(string, "OpenAI")
      name      = string
      version   = string
      publisher = optional(string)
      source    = optional(string)
    })
    version_upgrade_option = optional(string, "OnceNewDefaultVersionAvailable")
    rai_policy_name        = optional(string, "Microsoft.DefaultV2")
    }
  ))
  default = [{
    deployment_name = "gpt-4.1-nano"
    sku = {
      name     = "GlobalStandard"
      capacity = 1
    }
    model = {
      name    = "gpt-4.1-nano"
      version = "2025-04-14"
    }
  }]
}