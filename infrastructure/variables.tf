variable "environment" {
  type        = string
  description = "The deployment environment name (e.g., beta, staging, prod)."
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "East US 2"
}

variable "vnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the main Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_cidr" {
  type        = list(string)
  description = "The CIDR block for the AKS subnet."
  default     = ["10.0.1.0/24"]
}