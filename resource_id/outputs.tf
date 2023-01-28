output "value" {
  value = "${random_id.default.keepers.name}-${random_id.default.hex}"
}
