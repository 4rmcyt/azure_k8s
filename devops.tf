# Create the main Azure DevOps Project
resource "azuredevops_project" "main" {
  name               = var.azdo_project_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  description        = "FedRAMP-Ready GitOps Platform"
}

# Create the required Git repositories
resource "azuredevops_git_repository" "repos" {
  for_each  = toset(var.repository_names)
  project_id = azuredevops_project.main.id
  name       = each.key
  initialization {
    init_type = "Clean"
  }
}

# Create a placeholder build definition for the build validation policy
# This pipeline will be triggered by PRs to the 'main' branch of 'App-Code-mycorp'
# Assumes your pipeline definition is at 'azure-pipelines.yml' in that repo
resource "azuredevops_build_definition" "app_code_ci" {
  project_id = azuredevops_project.main.id
  name       = "App-Code-mycorp-CI"
  path       = "\\"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repos["App-Code-mycorp"].id
    branch_name = azuredevops_git_repository.repos["App-Code-mycorp"].default_branch
    yml_path    = "azure-pipelines.yml"
  }
}

# Apply the Build Validation Policy as required by the plan
resource "azuredevops_branch_policy_build_validation" "main_branch_policy" {
  project_id = azuredevops_project.main.id

  enabled   = true
  blocking  = true
  settings {
    display_name            = "CI Build Validation"
    build_definition_id     = azuredevops_build_definition.app_code_ci.id
    valid_duration          = 720 # Minutes (12 hours)
    filename_patterns       = ["/*"] # Run for all file changes
    manual_queue_only       = false
    queue_on_source_update_only = true

    scope {
      repository_id  = azuredevops_git_repository.repos["App-Code-mycorp"].id
      repository_ref = azuredevops_git_repository.repos["App-Code-mycorp"].default_branch
      match_type     = "Exact"
    }
  }
}