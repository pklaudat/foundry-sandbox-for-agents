terraform {
  required_providers {
    azurerm = {
      version = "~>4.6"
    }
    azuread = {
      version = "~>3.7"
    }
    random = {
      version = "~>3.8"
    }
  }
  required_version = "~>1.0"
}