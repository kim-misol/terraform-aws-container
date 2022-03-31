terraform {
  # Use GitLab-managed Terraform state
  # To run locally, do the following:
  # * Navigate to Settings > General and note your Project name and Project ID.
  # * Create a Personal Access Token with the api scope.
  # * Run gitlab-terraform-init.sh
  backend "http" {
  }
}

locals {
  context = yamldecode(file(var.config_file)).context
  config  = yamldecode(templatefile(var.config_file, local.context))
}

provider "aws" {
  alias = "dev"

  region = local.context.region
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = [local.context.allowed_account_ids]
}

module "cluster" {
  source  = "../../modules/eks-cluster"
  version = "0.14.0"

  name               = local.config.vpc.name
  kubernetes_version = var.kubernetes_version

  subnet_ids   = local.subnet_groups["public"].ids
  service_cidr = var.service_cidr

  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]
  endpoint_private_access      = true
  endpoint_private_access_cidrs = [
    local.vpc.cidr_block,
  ]

  log_types = [
    # "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]
  log_retention_in_days = 90
}

#module "network" {
#  source = "../../modules/network"
#
#  config_file = "./config.yaml"
#}
