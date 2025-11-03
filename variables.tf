variable "resource_group_name" {
  description = "Jacobia"
  type        = string
  default     = "Jacobia"
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

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}
