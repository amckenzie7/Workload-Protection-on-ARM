terraform {
  cloud {
    organization = "example-org-33046a"

    workspaces {
      name = "Minikube_on_ARM"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
