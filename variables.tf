variable "azdo_org_service_url" {
  type        = string
  description = "The URL for your Azure DevOps organization (e.g., 'https://dev.azure.com/YourOrgName')."
  sensitive   = true
}

variable "azdo_project_name" {
  type        = string
  description = "The name of the new Azure DevOps project."
  default     = "FedrampGitOpsPlatform"
}

variable "repository_names" {
  type        = list(string)
  description = "The list of Git repositories to create."
  default = [
    "Infra-Code-OpenTofu",
    "App-Code-mycorp",
    "K8s-Manifests-mycorp"
  ]
}