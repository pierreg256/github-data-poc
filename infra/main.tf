# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  # version = "=2.16.0"
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.47.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "__BACKENDRESOURCEGROUP__"
    storage_account_name = "__backendstorageaccount__"
    container_name       = "__application__"
    key                  = "__application__.terraform.tfstate"
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
  number  = false
  keepers = {
    resource_group_name = var.resourcegroup
  }
}

resource "random_string" "sharedKey" {
  length  = 32
  special = false
  upper   = true
  number  = true
  keepers = {
    resource_group_name = var.resourcegroup
  }
}

locals {
  resource_prefix        = var.application
  unique_resource_prefix = replace(lower("${var.application}${random_string.random.result}"), "/[^a-z]/", "")
  resource_group_name    = var.resourcegroup

  tags = {
    application = var.application
    deployment  = "terraform"
  }
}

# find the destination resource group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.tags
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

