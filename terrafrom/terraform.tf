# Terraform settings and provider pinning
# - Pinning provider versions avoids unexpected breaking changes when new provider
#   versions are released. Update the version intentionally.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
  }
}

# Configure AWS provider (default region for resources created by this configuration)
provider "aws" {
  region = "us-east-1"
}
