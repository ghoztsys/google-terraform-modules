locals {
  policies_map = distinct(flatten([
    for policy in var.iam_policies : [
      for role in policy.roles : [
        for member in policy.members : {
          role   = role
          member = member
        }
      ]
    ]
  ]))
}

resource "google_folder" "default" {
  display_name = var.name
  parent       = var.parent
}

resource "google_folder_iam_member" "default" {
  for_each = { for descriptor in local.policies_map : "${descriptor.member}+${descriptor.role}" => descriptor }

  folder = google_folder.default.name
  member = each.value.member
  role   = each.value.role
}
