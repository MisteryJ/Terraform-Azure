variable "resource_group_name" {
  description = "Name of the resource group to create."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westus2"
}

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}