variable "parent" {
  description = "Ther resource name of the parent folder or organization, in the form of `folders/{folder_id}` or `organizations/{org_id}`."
  type        = string
}

variable "name" {
  description = "Display name of the folder."
  type        = string
}

variable "iam_policies" {
  default     = []
  description = "IAM policies for the folder."
  type = list(object({
    members = list(string)
    roles   = list(string)
  }))
}
