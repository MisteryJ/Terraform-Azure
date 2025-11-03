terraform {
  cloud {
    organization = "jacobia"
    workspaces {
      name = "Terraform-Azure"
    }
  }
  required_version = ">= 1.3.0"
}
