variable app_id {
  description = "The app ID (i.e. `sybl-core`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instance."
}

variable environment {
  default = "development"
  description = "The environment of the resources, i.e. development, staging, etc. This value becomes a tag and label."
}
