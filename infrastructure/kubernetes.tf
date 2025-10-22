# This file configures Kubernetes resources via Tofu after the cluster is built.

# Define the custom premium stateful StorageClass
resource "kubernetes_storage_class_v1" "premium_stateful" {
  metadata {
    name = "premium-stateful-sc"
  }
  storage_provisioner = "disk.csi.azure.com" # Use the modern Azure Disk CSI driver
  reclaim_policy      = "Retain"             # Good for stateful data
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    skuName = "Premium_LRS" # Use Premium SSDs
    cachingMode = "ReadOnly" # Good for databases
  }
}