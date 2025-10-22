terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.7.0"
    }
  }
}