terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "example-org-a9609f"

    workspaces {
      name = "my-aws-app"
    }
  }

  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
