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
  type        = map(any)
  description = "Tags (K/V) to apply to resources"
  default = {
    ManagedBy = "terraform"
    Repo      = "aspenjames/ajdev-infra"
  }
}
