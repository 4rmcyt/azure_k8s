# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Configure the Kubernetes Provider
# It authenticates using the outputs from the created AKS cluster
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

# Configure the OpenTofu state backend (example using Azure Storage)
# You must create the storage account and container manually first.
/*
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateyourorg"
    container_name       = "tfstate"
    key                  = "infra.tfstate" # This will be per-workspace
  }
}
*/