variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "servicebus_namespace_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "Basic"
}

variable "queues" {
  description = "List of Service Bus queues to create"
  type = list(object({
    name                                 = string
    max_size_in_megabytes                = optional(number, 1024)
    default_message_ttl                  = optional(string, "P14D")
    lock_duration                        = optional(string, "PT1M")
    max_delivery_count                   = optional(number, 10)
    dead_lettering_on_message_expiration = optional(bool, true)
  }))
}