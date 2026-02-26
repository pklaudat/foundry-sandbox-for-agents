terraform {
  required_providers {
    azurerm = {
      version = "~>4.6"
    }
    azapi = {
      version = "~>2.8"
      source  = "azure/azapi"
    }
    azuread = {
      version = "~>3.7"
    }
  }
  required_version = "~>1.0"
}