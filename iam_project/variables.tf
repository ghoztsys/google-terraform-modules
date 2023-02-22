variable "policies" {
  default     = []
  description = "IAM policies."
  type = list(object({
    members = list(string)
    roles   = list(string)
  }))
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}
