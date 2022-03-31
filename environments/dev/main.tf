terraform {
  # Use GitLab-managed Terraform state
  # To run locally, do the following:
  # * Navigate to Settings > General and note your Project name and Project ID.
  # * Create a Personal Access Token with the api scope.
  # * Run gitlab-terraform-init.sh
  backend "http" {
  }
}

provider "aws" {
  alias = "dev"

  region = local.context.region
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = [local.context.allowed_account_ids]
}

module "network" {
  source = "../../modules/network"

  config_file = "./config.yaml"
}
