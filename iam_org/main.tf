locals {
  policies_map = flatten([
    for policy in var.policies : [
      for role in policy.roles : [
        for member in policy.members : {
          role   = role
          member = member
        }
      ]
    ]
  ])
}

resource "google_organization_iam_member" "organization" {
  for_each = { for descriptor in local.policies_map : "${descriptor.member}+${descriptor.role}" => descriptor }

  member = each.value.member
  org_id = var.org_id
  role   = each.value.role
}
