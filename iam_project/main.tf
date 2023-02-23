locals {
  policies_map = distinct(flatten([
    for policy in var.policies : [
      for role in policy.roles : [
        for member in policy.members : {
          role   = role
          member = member
        }
      ]
    ]
  ]))
}

resource "google_project_iam_member" "organization" {
  for_each = { for descriptor in local.policies_map : "${descriptor.member}+${descriptor.role}" => descriptor }

  member  = each.value.member
  project = var.project
  role    = each.value.role
}
