variable "fastly_api_key" {
  type        = string
  description = "API key for access to manage.fastly.com"
  sensitive   = true
}

variable "name" {
  type        = string
  description = "Identifier for multiple resources"
  default     = "ajdev"
}

variable "region" {
  type        = string
  description = "AWS region in which to deploy resources"
  default     = "us-west-2"
}

variable "tags" {
  type        = map(string)
  description = "Tags (K/V) to apply to resources"
  default = {
    ManagedBy = "terraform"
    Repo      = "aspenjames/ajdev-infra"
  }
}
