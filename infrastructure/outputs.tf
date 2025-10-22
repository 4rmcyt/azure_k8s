output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_kube_config_admin" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

# --- ADDED ---
output "argocd_identity_client_id" {
  description = "The Client ID for the ArgoCD User-Assigned Identity."
  value       = azurerm_user_assigned_identity.argocd.client_id
}