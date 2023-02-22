output "display_name" {
  description = "The folder's display name."
  value       = google_folder.default.display_name
}

output "id" {
  description = "Folder ID."
  value       = google_folder.default.folder_id
}

output "name" {
  description = "The name of the folder, format: `folders/{folder_id}`."
  value       = google_folder.default.name
}

output "parent" {
  description = "The resource name of the parent folder or organization, in the form of `folders/{folder_id}` or `organizations/{org_id}`."
  value       = google_folder.default.parent
}
