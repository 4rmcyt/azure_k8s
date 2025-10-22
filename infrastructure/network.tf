# Get client config for Key Vault permissions
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-gitops"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.aks_subnet_cidr
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${replace(var.environment, "-", "")}gitops"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"
  admin_enabled       = false
}

# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.environment}-gitops"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
}

# Add a key for SOPS to use for encryption/decryption
resource "azurerm_key_vault_key" "sops" {
  name         = "sops-master-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.environment}"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    node_count = 3
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Private Cluster
  private_cluster_enabled = true
  oidc_issuer_enabled = true

  # Enable Azure CNI and Azure Network Policy
  network_profile {
    network_plugin = "azure"
    network_policy = "azure" # This enables the policy engine
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  # Enable Azure Monitor for containers
  oms_agent {
    log_analytics_workspace_id = null # Add a Log Analytics Workspace ID here
  }
}

