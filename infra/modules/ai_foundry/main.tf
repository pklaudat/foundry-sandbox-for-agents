
resource "azapi_resource" "this" {
  type      = "Microsoft.CognitiveServices/accounts@2025-10-01-preview"
  parent_id = var.resource_group_id
  name      = var.name
  location  = var.location
  identity {
    type         = "SystemAssigned"
    identity_ids = []
  }
  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    properties = {
      allowProjectManagement        = true
      allowedFqdnList               = var.allowed_egress_fqdns
      disableLocalAuth              = true
      restrictOutboundNetworkAccess = true
      publicNetworkAccess           = "Enabled"
      customSubDomainName           = var.name
      networkAcls = {
        bypass  = "AzureServices"
        ipRules = [for ip in var.allowed_ips_to_access : { value = ip }]
      }
      dynamicThrottlingEnabled = true
    }
  }
  response_export_values = ["*"]
}



output "id" {
  value       = azapi_resource.this.id
  description = "the resource id for the ai foundry."
}

output "endpoint" {
  value       = azapi_resource.this.output.properties.endpoint
  description = "the ai foundry endpoint."
}