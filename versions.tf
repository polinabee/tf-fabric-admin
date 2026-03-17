terraform {
  required_version = ">= 1.5.0"

  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = ">= 0.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}
