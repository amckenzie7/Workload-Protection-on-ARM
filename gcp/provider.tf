terraform {
  cloud {
    organization = "example-org-33046a"

    workspaces {
      name = "k3s-on-arm"
    }
  }
}

provider "google" {
  region  = var.gcp_region
  project = var.project_id
}
