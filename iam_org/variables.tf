variable "org_id" {
  description = "Organization ID"
  type        = string
}

variable "policies" {
  default     = []
  description = "IAM policies."
  type = list(object({
    members = list(string)
    roles   = list(string)
  }))
}
