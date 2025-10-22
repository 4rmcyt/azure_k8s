# This file configures a new identity for ArgoCD to use for decrypting SOPS secrets.

# 1. Create a User-Assigned Identity for ArgoCD
resource "azurerm_user_assigned_identity" "argocd" {
  name                = "identity-argocd-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# 2. Grant this identity the "Key Vault Crypto User" role
# This allows it to perform decryption operations using keys.
resource "azurerm_role_assignment" "argocd_kv_decrypt" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.argocd.principal_id
}

# 3. Establish the trust relationship between Kubernetes and the Azure Identity
# This tells Azure to trust the "argocd/argocd-repo-server" ServiceAccount
# in our AKS cluster.
resource "azurerm_federated_identity_credential" "argocd" {
  name                = "argocd-sops-federation"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.argocd.id
  
  # This MUST match the namespace and service account name ArgoCD uses
  subject             = "system:serviceaccount:argocd:argocd-repo-server" 
}