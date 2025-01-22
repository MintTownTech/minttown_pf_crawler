# -------------------------------------
# General
# -------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }
}

# -------------------------------------
provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      env       = var.env
      ManagedBy = "terraform"
    }
  }
}
