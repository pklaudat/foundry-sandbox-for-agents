variable "location" {
  type        = string
  description = "The location for the azure resources."
  default     = "eastus"
}

variable "prefix_name" {
  type        = string
  description = "prefix name for azure resources."
}

variable "environment" {
  type        = string
  description = "Environment definition."
  default     = "dev"
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "environment not available, allowed values: [ dev, stg, prod ]."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "additional tags to append into the resources."
}


variable "allowed_ips_to_access" {
  description = "allowed ip addresses to access the ai foundry instance."
  type        = list(string)
  default     = []
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

variable "allowed_fqdn_ai_services" {
  type        = list(string)
  description = "list of egress urls the ai services are allowed to connect."
  default     = []
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

variable "serverless_mcp_servers" {
  type = list(object({
    name = string
    runtime_name = optional(string, "python")
    runtime_version = optional(string, "3.13")
    zip_code_deploy = string
  }))
  description = "list of serverless mcp servers to be deployed using azure functions."
  default = []
}