variable "project_id" {
  description = "ID of project to create resources in."
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
